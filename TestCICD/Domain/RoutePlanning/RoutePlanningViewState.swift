//
//  RoutePlanningViewState.swift
//  EVP4
//
//  Created by Woramet Muangsiri on 2022/08/10.
//

import Foundation
import Combine
import heresdk

class RoutePlanningViewState: ViewState, ObservableObject {
    enum State: Equatable, CaseReflectable {
        case idle(_ motorcycleLocation: GeoCoordinates? = nil)
        case showingRecentSearches(SearchResultView.SearchResult)
        case showingSearchResults(SearchResultView.SearchResult)
        case showingDetail(_ place: Place)
        case routing(_ place: Place?, _ selectedRoute: Route?, _ routes: [Route])
        case maneuvering(_ place: Place?, _ selectedRoute: Route?)
        case routeShared
    }

    @Published var currentState: State = .idle(nil)

    // MapView
    @Published var mapViewState: HEREMapViewState = HEREMapViewState()
    // Search
    @Published var searchBarViewState: SearchBarViewState = SearchBarViewState()
    @Published private(set) var searchResult: SearchResultView.SearchResult?
    @Published private(set) var isSearchResultHidden: Bool = true
    // Share
    @Published var isShowingOptions = false
    // DetailInfo
    @Published private(set) var detailInfoState: DetailInfoView.DetailInfoState = .hidden

    private var cancellableSet: Set<AnyCancellable> = []

    init(state: AppState, action: RoutePlanningAction?) {
        // TODO: Think a better way for this
        searchBarViewState.$searchText
            .debounce(for: .seconds(0.4), scheduler: DispatchQueue.main)
            .sink { action?.do(.search(keyword: $0, geo: self.mapViewState.motorcycleCoordinates)) }
            .store(in: &cancellableSet)

        searchBarViewState.$isEditing
            .dropFirst(1)
            .removeDuplicates()
            .sink { action?.do($0 ? .startSearching : .endSearching) }
            .store(in: &cancellableSet)
        searchBarViewState.$isEmpty
            .dropFirst(1)
            .filter { $0 }
            .removeDuplicates()
            .sink { _ in action?.do(.startSearching) }
            .store(in: &cancellableSet)

        $currentState
            .sink(receiveValue: resolveState(_:))
            .store(in: &cancellableSet)
    }
}

// Resolve view state
extension RoutePlanningViewState {
    private func resolveState(_ state: State) {
        switch state {
        case .idle(let motorcycleGeo):
            updateIdle(motorcycleGeo)

        case .showingRecentSearches(let result):
            updateShowingRecentSearches(result)

        case .showingSearchResults(let result):
            updateShowingSearchResults(result)

        case .showingDetail(let place):
            updateShowingDetail(place)

        case .routing(let place, let route, let routes):
            updateRouting(place, route, routes)

        case .maneuvering(let place, let route):
            updateManeuvering(place, route)

        case .routeShared:
            break
        }
    }

    private func updateIdle(_ motorcycleGeo: GeoCoordinates? = nil) {
        // Map
        if let motorcycleGeo = motorcycleGeo {
            mapViewState.motorcycleCoordinates = motorcycleGeo
            mapViewState.cameraTargetCoordinates = motorcycleGeo
        }
        mapViewState.selectedRouteIndex = nil
        mapViewState.routes = []
        // Search
        searchResult = nil
        isSearchResultHidden = true
        // Share
        isShowingOptions = false
        // DetailInfo
        detailInfoState = .hidden
    }

    private func updateShowingRecentSearches(_ result: SearchResultView.SearchResult) {
        // Map - no change
        // Search
        searchResult = result
        isSearchResultHidden = false
        // Share
        isShowingOptions = false
        // DetailInfo
        detailInfoState = .hidden
    }

    private func updateShowingSearchResults(_ result: SearchResultView.SearchResult) {
        // Map - no change
        // Search
        searchResult = result
        isSearchResultHidden = false
        // Share
        isShowingOptions = false
        // DetailInfo
        detailInfoState = .hidden
    }

    private func updateShowingDetail(_ place: Place) {
        // Map
        mapViewState.destinationPlace = place
        mapViewState.selectedRouteIndex = nil
        mapViewState.routes = []
        // Search
        searchResult = nil
        isSearchResultHidden = true
        // Share
        isShowingOptions = false
        // DetailInfo
        detailInfoState = .show(place)
    }

    private func updateRouting(_ place: Place?, _ selectedRoute: Route?, _ routes: [Route]) {
        // Map
        mapViewState.routes = routes
        if !routes.isEmpty, mapViewState.selectedRouteIndex == nil {
            mapViewState.selectedRouteIndex = 0
        }
        // Search
        searchResult = nil
        isSearchResultHidden = true
        // Share
        isShowingOptions = false
        // DetailInfo
        if let place = place, let selectedRoute = selectedRoute {
            detailInfoState = .showRouteInfo(place, selectedRoute)
        } else {
            detailInfoState = .hidden
        }
    }

    private func updateManeuvering(_ place: Place?, _ selectedRoute: Route?) {
        // Search
        searchResult = nil
        isSearchResultHidden = true
        // Share
        isShowingOptions = false
        if let place = place, let selectedRoute = selectedRoute {
            detailInfoState = .showManeuverInfo(place, selectedRoute)
        } else {
            detailInfoState = .hidden
        }
    }
}
