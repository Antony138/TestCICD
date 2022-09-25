//
//  HEREMapViewState.swift
//  EVP4
//
//  Created by Stone Zhang on 8/26/22.
//

import Foundation
import heresdk

class HEREMapViewState: ObservableObject {
    // Camera
    @Published var cameraTargetCoordinates: GeoCoordinates?
    @Published var viewRegion: GeoBox?
    // Route
    @Published var motorcycleCoordinates: GeoCoordinates?
    @Published var destinationPlace: Place?
    @Published var routes: [Route] = []
    @Published var selectedRouteIndex: Int?
    var selectedRoute: Route? {
        guard let selectedRouteIndex = selectedRouteIndex else { return nil }
        guard selectedRouteIndex >= 0 && selectedRouteIndex < routes.count else { return nil }
        return routes[selectedRouteIndex]
    }

    // Avoid update loop
    var shouldUpdateView: Bool = true
}
