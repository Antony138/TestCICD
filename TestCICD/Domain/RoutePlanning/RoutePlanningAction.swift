//
//  RoutePlanningAction.swift
//  EVP4
//
//  Created by Woramet Muangsiri on 2022/08/10.
//

import Foundation
import heresdk
import Combine
import CoreBluetooth

class RoutePlanningAction {

    enum Action: Equatable {
        case showMotorcyclePin
        case startSearching
        case search(keyword: String, geo: GeoCoordinates?)
        case selectSearchResult(_ place: Place)
        case selectDestination(_ place: Place)
        case selectDestinationByLongpress(_ geo: GeoCoordinates)
        case selectRoute(_ route: Route)
        case viewRoute(_ route: Route)
        case endSearching
        case showOption
        case shareRoute(_ option: ShareOption)
        case toggleFav(_ isFav: Bool)
    }

    private let store: AppStore
    private var cancellableSet: Set<AnyCancellable> = []

    private var viewState: RoutePlanningViewState {
        guard let viewState = store.foundation.router.viewState(RoutePlanningViewState.self) else {
            fatalError("RoutePlanningViewState not found")
        }
        return viewState
    }
    // Route planning
    enum Constants {
        static let dummyStartLocation = GeoCoordinates(latitude: 35.6467033, longitude: 139.7075485)
    }
    private var navigator: Navigatable { store.foundation.navigator }
    // Bluetooth communication
    enum ShareOption {
        case geoCoordinates
        case place
        case gpxTrace
        case routeHandle
    }
    private var bluetoothService: BluetoothKit { store.foundation.bluetoothService }
    private var userDefaults: UserDefaults { store.foundation.userDefault }
    private var l2capChannel: L2CAPChannel?

    init(store: AppStore) {
        self.store = store
        // Can not open L2CAP if call the method immediately
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.openCentralL2CAPChannel()
        }
    }

    /// Perform an action from the View
    /// This is the only function that View can access
    func `do`(_ action: Action) {
        switch action {
        case .showMotorcyclePin:
            showMotorcycleLocation()

        case .startSearching:
            viewState.currentState =
                .showingRecentSearches(SearchResultView.SearchResult(title: "Recent searches",
                                                                     places: userDefaults.recentPlaces))

        case .search(keyword: let keyword, geo: let geo):
            search(with: keyword, near: geo)

        case .selectSearchResult(let place):
            // FIXME: This is also workaround. need properway to communicate back with subview.
            viewState.searchBarViewState.isEditing = false
            viewState.mapViewState.cameraTargetCoordinates = place.geoCoordinates
            viewState.currentState = .showingDetail(place)

        case .selectDestination(let place):
            selectDestination(place)
            var places = userDefaults.recentPlaces
            places.append(place)
            userDefaults.recentPlaces = places

        case .selectDestinationByLongpress(let geo):
            setDestinationLocation(geo)

        case .selectRoute(let route):
            selectRoute(route)

        case .viewRoute(let route):
            viewRoute(route)

        case .endSearching:
            viewState.currentState = .idle()

        case .showOption:
            showOptions()

        case .shareRoute(let option):
            shareRoute(option: option)

        case .toggleFav(let isFav):
            toggleFav(isFav)
        }
    }
}

// MARK: - Route Planning
private extension RoutePlanningAction {

    func showMotorcycleLocation() {
        viewState.currentState = .idle(Constants.dummyStartLocation)
    }

    func setDestinationLocation(_ location: GeoCoordinates) {
        Task { @MainActor in
            if let place = try? await self.navigator.getAddressForCoordinates(geoCoordinates: location).first {
                viewState.mapViewState.destinationPlace = place
                viewState.currentState = .showingDetail(place)
            } else {
                // unfortunately something wrong.
            }
        }
    }

    func search(with keyword: String, near geo: GeoCoordinates?) {
        guard let geo = geo else { return }
        Task { @MainActor in
            let places = try? await self.navigator.getAddresses(from: keyword, near: geo)

            if let places = places {
                viewState.currentState = .showingSearchResults(SearchResultView.SearchResult(title: "results", places: places))
            } else {
                // TODO: show empty search result
            }
        }
    }

    func selectDestination(_ place: Place) {
        viewState.mapViewState.destinationPlace = place
        Task { @MainActor in
            if let start = self.viewState.mapViewState.motorcycleCoordinates,
               let end = place.geoCoordinates,
               let routes = try? await self.navigator.calculateRoute(start: start, destination: end, numberOfAltRoute: 2) {
                viewState.currentState = .routing(place, routes.first, routes)
                let vertices = routes.flatMap(\.geometry.vertices)
                let latitudes = vertices.map(\.latitude)
                let longitudes = vertices.map(\.longitude)
                // TODO: Need to consider cross -180/180 longitude
                if let minLatitude = latitudes.min(),
                   let maxLatitude = latitudes.max(),
                   let minLongitude = longitudes.min(),
                   let maxLongitude = longitudes.max() {
                    viewState.mapViewState.viewRegion = GeoBox(southWestCorner: GeoCoordinates(latitude: minLatitude, longitude: minLongitude),
                                                               northEastCorner: GeoCoordinates(latitude: maxLatitude, longitude: maxLongitude))
                }
            }
        }
    }

    func selectRoute(_ newRoute: Route) {
        switch viewState.currentState {
        case .routing(let place, _, let routes):
            viewState.currentState = .routing(place, newRoute, routes)
        default:
            break
        }
    }

    func viewRoute(_ route: Route) {
        switch viewState.currentState {
        case .routing(let place, _, _):
            viewState.currentState = .maneuvering(place, route)
        default:
            break
        }
    }
}

// MARK: - Bluetooth Communication
private extension RoutePlanningAction {

    func openCentralL2CAPChannel() {
        bluetoothService.centralManager
            .scanPeripherals(withServices: [L2CAP.serviceUUID], options: nil)
            .flatMap { $0.centralManager.connect(peripheral: $0.peripheral, options: nil, isStopScanAfterConected: true) }
            .flatMap { $0.connectedPeripheral.discoverServices(serviceUUIDs: [L2CAP.serviceUUID]) }
            .flatMap { $0.discoverCharacteristics(characteristicUUIDs: [L2CAP.PSMUUID]) }
            .flatMap { $0.observeValue() }
            .flatMap { $0.peripheral.openL2CAPChannel($0.value.uint16) }
            .flatMap { $0.setupL2CAPChannel($0.cbChannel) }
            .sink { [weak self] result in
                self?.l2capChannel = result.channel

                switch result.eventCode {
                case Stream.Event.openCompleted:
                    print("@ Demo: L2CAP Stream is open")

                case Stream.Event.endEncountered:
                    print("@ Demo: L2CAP End Encountered")

                case Stream.Event.hasBytesAvailable:
                    print("@ Demo: L2CAP Has Bytes Available: \(result.aStream)")

                case Stream.Event.hasSpaceAvailable:
                    print("@ Demo: L2CAP Has Space Available")

                case Stream.Event.errorOccurred:
                    print("@ Demo: L2CA Stream error")

                default:
                    print("@ Demo: L2CA Unknown stream event")
                }
            }
            .store(in: &cancellableSet)
    }

    func showOptions() {
        viewState.isShowingOptions = true
    }

    func shareRoute(option: ShareOption) {
        var data: Data?
        switch option {
        case .geoCoordinates: data = geoCoordinatesData
        case .place:
            Task { @MainActor in
                guard let data = try? await placeData() else { return }
                self.shareRoute(data)
            }
            return
        case .gpxTrace: data = gpxTraceData
        case .routeHandle: data = routeHandleData
        }
        guard let data = data else { return }
        shareRoute(data)
    }

    private func shareRoute(_ data: Data) {
        guard let l2capChannel = l2capChannel else {
            print("l2capChannel is nil")
            return
        }
        let result = l2capChannel.send(data: data)
        print("send data result: \(result)")

        store.foundation.router.present(.navigating(store: store))
    }

    private var geoCoordinatesData: Data? {
        guard let geoCoordinates = viewState.mapViewState.destinationPlace?.geoCoordinates else {
            print("destinationLocation not found")
            return nil
        }
        do {
            var data = try JSONEncoder().encode(geoCoordinates)
            data.insert(ShareOption.geoCoordinates.typeByte, at: 0)
            data.append(255)
            return data
        } catch {
            print("destination encode error : \(error)")
            return nil
        }
    }

    private func placeData() async throws -> Data? {
        guard let location = viewState.mapViewState.destinationPlace?.geoCoordinates else { return nil }
        guard let place = try? await navigator.getAddressForCoordinates(geoCoordinates:location).first else { return nil }
        guard var data = place.serializeCompact().data(using: .utf8) else {
            print("serializedDestinationData is nil")
            return nil
        }
        data.insert(ShareOption.place.typeByte, at: 0)
        data.append(255)
        return data
    }

    private var gpxTraceData: Data? {
        guard let routeTrace = viewState.mapViewState.selectedRoute?.geometry.vertices else {
            print("gpxTrace not found")
            return nil
        }
        do {
            var data = try JSONEncoder().encode(routeTrace)
            data.insert(ShareOption.gpxTrace.typeByte, at: 0)
            data.append(255)
            return data
        } catch {
            print("gxpTraceData encode error : \(error.localizedDescription)")
            return nil
        }
    }

    private var routeHandleData: Data? {
        guard var data = viewState.mapViewState.selectedRoute?.routeHandle?.handle.data(using: .utf8) else {
            print("routeHandle is nil")
            return nil
        }
        data.insert(ShareOption.routeHandle.typeByte, at: 0)
        data.append(255)
        return data
    }

    private func toggleFav(_ isFav: Bool) {
        if isFav {
            print("Add to fav list")
        } else {
            print("Remove from fav list")
        }
    }

}

// MARK: - GeoCoordinates

// Make GeoCoordinates(From heresdk) Encodable and Decodable
extension GeoCoordinates: Codable {
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case altitude
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        let altitude = try container.decode(Double?.self, forKey: .altitude)
        self = GeoCoordinates(latitude: latitude, longitude: longitude, altitude: altitude ?? 0.0)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(altitude, forKey: .altitude)
    }
}

// MARK: - Protocol for four options (geo, obj, gpx, handle)

// For Meter:
// use 0, 1, 2, 3 to identify which type of data it is
// this UInt8 will store at the first byte of the data
// and use OxFF to identify the end of the data
// examples:
// 007B22616CFF, type: geoCoordinates,        pure data: 7B22616C
// 017B22616CFF, type: serializedPlaceObject, pure data: 7B22616C
extension RoutePlanningAction.ShareOption {
    var typeByte: UInt8 {
        switch self {
        case .geoCoordinates: return 0x00
        case .place: return 0x01
        case .gpxTrace: return 0x02
        case .routeHandle: return 0x03
        }
    }
}

// Test L2CAP Channel
enum L2CAP {
    static let serviceUUID = CBUUID(string:"12E61727-B41A-436F-B64D-4777B35F2294")
    static let PSMUUID = CBUUID(string:CBUUIDL2CAPPSMCharacteristicString)
}
