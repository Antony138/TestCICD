//
//  HEREMapView.swift
//  EVP4
//
//  Created by Stone Zhang on 8/25/22.
//

import SwiftUI
import heresdk

struct HEREMapView: UIViewRepresentable {
    typealias MapPin = MapView.ViewPin

    @ObservedObject var viewState: HEREMapViewState
    let didLongPressCoordinates: ((GeoCoordinates) -> Void)?
    let didTapRoute: ((Route) -> Void)?

    enum MarkerIdentifier {
        case motorcycle
        case destination

        var imageName: String {
            switch self {
            case .motorcycle: return "TEMP_moto_pin"
            case .destination: return "red_pin"
            }
        }
    }

    struct Marker {
        let mapMarker: MapMarker
        let mapPin: MapPin?
    }

    struct Polyline {
        let mapPolyline: MapPolyline
        let mapPin: MapPin?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MapView {
        let mapView = MapView()
        mapView.mapScene.loadScene(mapScheme: .normalDay, completion: nil)
        mapView.camera.addDelegate(context.coordinator)
        mapView.gestures.longPressDelegate = context.coordinator
        mapView.gestures.tapDelegate = context.coordinator
        context.coordinator.mapView = mapView
        return mapView
    }

    func updateUIView(_ mapView: MapView, context: Context) {
        guard viewState.shouldUpdateView else {
            print("[HEREMapView] - Skip updating map view")
            viewState.shouldUpdateView = true
            return
        }
        print("[HEREMapView] - Update map view")
        updateCameraTargetCoordinates(mapView: mapView,
                                      coordinates: viewState.cameraTargetCoordinates)
        updateCameraViewRegion(mapView: mapView,
                               viewRegion: viewState.viewRegion)
        updateMarker(mapView: mapView,
                     coordinator: context.coordinator,
                     identifier: .motorcycle,
                     coordinates: viewState.motorcycleCoordinates,
                     label: nil,
                     drawOrder: 1000)
        updateMarker(mapView: mapView,
                     coordinator: context.coordinator,
                     identifier: .destination,
                     coordinates: viewState.destinationPlace?.geoCoordinates,
                     label: viewState.destinationPlace?.title,
                     drawOrder: 1001)
        updateRoute(mapView: mapView,
                    coordinator: context.coordinator,
                    routes: viewState.routes)
    }

    private func updateCameraTargetCoordinates(mapView: MapView,
                                               coordinates: GeoCoordinates?) {
        guard coordinates != mapView.camera.state.targetCoordinates else {
            print("[HEREMapView] - Same camera target coordinates")
            return
        }
        guard let coordinates = coordinates else { return }
        mapView.camera.lookAt(point: coordinates,
                              zoom: MapMeasure(kind: .distance, value: 5000))
    }

    private func updateCameraViewRegion(mapView: MapView,
                                        viewRegion: GeoBox?) {
        guard viewRegion != mapView.camera.boundingBox else {
            print("[HEREMapView] - Same camera view region")
            return
        }
        guard let viewRegion = viewRegion else { return }
        let orientation = GeoOrientationUpdate(bearing: mapView.camera.state.orientationAtTarget.bearing,
                                               tilt: mapView.camera.state.orientationAtTarget.tilt)
        let origin = Point2D(x: 100, y: 100)
        let sizeInPixels = Size2D(width: mapView.viewportSize.width - 200, height: mapView.viewportSize.height - 200)
        let mapViewportWithPadding = Rectangle2D(origin: origin, size: sizeInPixels)
        mapView.camera.lookAt(area: viewRegion, orientation: orientation, viewRectangle: mapViewportWithPadding)
    }

    // swiftlint:disable:next function_parameter_count
    private func updateMarker(mapView: MapView,
                              coordinator: Coordinator,
                              identifier: MarkerIdentifier,
                              coordinates: GeoCoordinates?,
                              label: String?,
                              drawOrder: Int32) {
        // Remove existing MapMarker and MapPin
        if let marker = coordinator.markers[identifier] {
            if marker.mapMarker.coordinates == coordinates {
                print("[HEREMapView] - Same marker `\(identifier)` `\(coordinator)`")
                return
            }
            mapView.mapScene.removeMapMarker(marker.mapMarker)
            marker.mapPin?.unpin()
            coordinator.markers[identifier] = nil
        }
        guard let coordinates = coordinates else { return }
        // Add MapMarker
        let mapMarker = MapMarker(coordinates: coordinates, imageName: identifier.imageName)
        mapMarker.drawOrder = drawOrder
        mapView.mapScene.addMapMarker(mapMarker)
        // Add MapPin
        var mapPin: MapPin?
        if let label = label {
            let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 150, height: 60))
            textView.text = label
            textView.textAlignment = .left
            textView.textColor = .red
            textView.backgroundColor = .clear
            textView.font = .boldSystemFont(ofSize: 16)
            textView.isEditable = false
            textView.isScrollEnabled = false
            textView.layer.anchorPoint = CGPoint(x: -0.1, y: 0.5)
            textView.textContainer.maximumNumberOfLines = 2
            textView.textContainer.lineBreakMode = .byTruncatingTail
            mapPin = mapView.pinView(textView, to: coordinates)
        }
        // Save new marker
        let newMarker = Marker(mapMarker: mapMarker, mapPin: mapPin)
        coordinator.markers[identifier] = newMarker
    }

    private func updateRoute(mapView: MapView,
                             coordinator: Coordinator,
                             routes: [Route]) {
        // Remove existing MapPolylines and MapPins
        if coordinator.polylines.isEmpty == false {
            coordinator.polylines.map(\.mapPolyline).forEach { mapView.mapScene.removeMapPolyline($0) }
            coordinator.polylines.map(\.mapPin).forEach { $0?.unpin() }
            coordinator.polylines = []
        }
        guard routes.isEmpty == false else { return }
        guard let minDuration = routes.map(\.duration).min() else { return }
        routes.enumerated().forEach {
            let isSelected = viewState.selectedRouteIndex == $0.offset
            // Add MapPolyline
            let mapPolyline = MapPolyline(route: $0.element,
                                          isSelected: isSelected)
            mapPolyline.drawOrder = isSelected ? Int32(999) : Int32($0.offset)
            mapView.mapScene.addMapPolyline(mapPolyline)
            // Add MapPin
            var mapPin: MapPin?
            if isSelected {
                let textView = UITextView()
                textView.text = $0.element.label(isFastest: $0.element.duration == minDuration)
                textView.textAlignment = .center
                textView.textColor = .white
                textView.backgroundColor = .selectedRoute
                textView.font = .systemFont(ofSize: 16)
                textView.isEditable = false
                textView.isScrollEnabled = false
                textView.sizeToFit()
                textView.layer.anchorPoint = CGPoint(x: 1.25, y: 0.5)
                if let coordinates = $0.element.midCoordinates {
                    mapPin = mapView.pinView(textView, to: coordinates)
                }
            }
            // Save new polyline
            let newPolyline = Polyline(mapPolyline: mapPolyline, mapPin: mapPin)
            coordinator.polylines.append(newPolyline)
        }
    }

    class Coordinator: NSObject, MapCameraDelegate, LongPressDelegate, TapDelegate {
        let hereMapView: HEREMapView
        var markers: [MarkerIdentifier: Marker] = [:]
        var polylines: [Polyline] = []
        weak var mapView: MapView?

        init(_ hereMapView: HEREMapView) {
            self.hereMapView = hereMapView
        }

        func onMapCameraUpdated(_ cameraState: MapCamera.State) {
            print("[HEREMapView] - Update camera")
            hereMapView.viewState.shouldUpdateView = false
            hereMapView.viewState.cameraTargetCoordinates = cameraState.targetCoordinates
            hereMapView.viewState.viewRegion = mapView?.camera.boundingBox
        }

        func onLongPress(state: heresdk.GestureState, origin: Point2D) {
            guard state == .begin else { return }
            guard let coordinates = mapView?.viewToGeoCoordinates(viewCoordinates: origin) else { return }
            hereMapView.didLongPressCoordinates?(coordinates)
        }

        func onTap(origin: Point2D) {
            mapView?.pickMapItems(at: origin, radius: 16) { pickMapItemsResult in
                guard let result = pickMapItemsResult else {
                    print("[HEREMapView] - Empty result")
                    return
                }
                guard let mapPolyline = result.polylines.first else {
                    print("[HEREMapView] - Polyline not found")
                    return
                }
                guard let index = self.polylines.map(\.mapPolyline).firstIndex(of: mapPolyline) else {
                    print("[HEREMapView] - Polyline index not found")
                    return
                }
                guard index < self.hereMapView.viewState.routes.count else { return }
                self.hereMapView.viewState.selectedRouteIndex = index
                if let route = self.hereMapView.viewState.selectedRoute {
                    self.hereMapView.didTapRoute?(route)
                }
            }
        }
    }

}

extension MapMarker {
    convenience init(coordinates: GeoCoordinates,
                     imageName: String) {
        guard let data = UIImage(named: imageName)?.pngData() else {
            fatalError("Couldn't get image data from `\(imageName)`")
        }
        let image = MapImage(pixelData: data, imageFormat: ImageFormat.png)
        self.init(at: coordinates, image: image, anchor: .init(horizontal: 0.5, vertical: 1))
    }
}

extension MapPolyline {
    convenience init(route: Route,
                     isSelected: Bool) {
        self.init(geometry: route.geometry,
                  widthInPixels: 16,
                  color: isSelected ? .selectedRoute : .defaultRoute)
    }
}

extension Route {
    var midCoordinates: GeoCoordinates? {
        let vertices = geometry.vertices
        guard vertices.isEmpty == false else { return nil }
        return vertices[vertices.count / 2]
    }

    func label(isFastest: Bool) -> String {
        let minutes = Int(duration / 60)
        if isFastest {
            return "\(minutes) min.\nFastest"
        } else {
            return "\(minutes) min."
        }
    }
}

extension UIColor {
    static var defaultRoute: UIColor { UIColor(hex: "#97D2FFFF") ?? .cyan }
    static var selectedRoute: UIColor { UIColor(hex: "#2D9BF0FF") ?? .blue }
}
