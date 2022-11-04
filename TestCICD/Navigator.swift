//
//  Navigator.swift
//  EVP4
//
//  Created by Woramet Muangsiri on 2022/08/18.
//

import Foundation
import Combine
import heresdk

protocol Navigatable {
    func calculateRoute(start: GeoCoordinates,
                        destination: GeoCoordinates,
                        numberOfAltRoute: Int32) async throws -> [Route]
    func getAddressForCoordinates(geoCoordinates: GeoCoordinates) async throws -> [Place]
    func getAddresses(from keyword: String, near geo: GeoCoordinates, max: Int32) async throws -> [Place]
}

// Default parameters for `Navigatable`
extension Navigatable {
    func getAddresses(from keyword: String, near geo: GeoCoordinates, max: Int32 = 30) async throws -> [Place] {
        return try await getAddresses(from: keyword, near: geo, max: max)
    }

    func calculateRoute(start: GeoCoordinates,
                        destination: GeoCoordinates,
                        numberOfAltRoute: Int32 = 0) async throws -> [Route] {
        return try await calculateRoute(start: start, destination: destination, numberOfAltRoute: numberOfAltRoute)
    }
}

class Navigator: Navigatable {
    // MARK: - Properties
    private var cancellableSet: Set<AnyCancellable> = []
    private var onlineRoutingEngine: RoutingEngine?
    private var searchEngine: SearchEngine?

    // MARK: - Initializer
    /// Preferred initializer
    /// - Parameter onlineRoutingEngine: Here's SDK RoutingEngine
    /// - Parameter searchEngine: Here's SDK SearchEngine
    init(credentialID: String,
         credentialSecret: String,
         onlineRoutingEngine: RoutingEngine? = nil,
         searchEngine: SearchEngine? = nil) {
        // Set credential
        let options = SDKOptions(accessKeyId: credentialID, accessKeySecret: credentialSecret)
        do {
            try SDKNativeEngine.makeSharedInstance(options: options)
        } catch let engineInstantiationError {
            fatalError("Failed to initialize the HERE SDK. Cause: \(engineInstantiationError)")
        }
        // Set route engine
        if let routeEngine = onlineRoutingEngine {
            self.onlineRoutingEngine = routeEngine
        } else {
            do {
                try self.onlineRoutingEngine = RoutingEngine()
            } catch let engineInstantiationError {
                fatalError("Failed to initialize routing engine. Cause: \(engineInstantiationError)")
            }
        }
        // Set search engine
        if let searchEngine = searchEngine {
            self.searchEngine = searchEngine
        } else {
            do {
                try self.searchEngine = SearchEngine()
            } catch let engineInstantiationError {
                fatalError("Failed to initialize routing engine. Cause: \(engineInstantiationError)")
            }
        }
    }
}

// MARK: - Navigation
extension Navigator {
    /// Calculate route
    /// - Parameters:
    ///   - start: start's geocoordinates
    ///   - destination: destination's geocoordinates
    ///   - numberOfRoute: Number of alternative routes in range [0, 6]. The default is 0.
    ///   Does not guarantee the exact number of route available.
    /// - Returns: A list of Route if successful. Otherwise, return empty array.
    func calculateRoute(start: GeoCoordinates,
                        destination: GeoCoordinates,
                        numberOfAltRoute: Int32 = 0) async throws -> [Route] {

        // At some point, make the caroption injectable.
        var carOptions = CarOptions()
        carOptions.routeOptions.enableRouteHandle = true
        carOptions.routeOptions.alternatives = numberOfAltRoute

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[Route], Error>) in
            onlineRoutingEngine?.calculateRoute(with: [Waypoint(coordinates: start),
                                                       Waypoint(coordinates: destination)],
                                                carOptions: carOptions) { error, routes in

                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: routes ?? [])
                }

            }
        }
    }
}

// MARK: - Search
extension Navigator {
    /// Performs an async request to search for places based on given geographic coordinates.
    /// - Parameter geoCoordinates: a GeoCoordinates
    /// - Returns: return a List of places. usually it contains only one item.
    func getAddressForCoordinates(geoCoordinates: GeoCoordinates) async throws -> [Place] {

        let reverseGeocodingOptions = SearchOptions(languageCode: LanguageCode.enUs, maxItems: 1)

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[Place], Error>) in

            searchEngine?.search(coordinates: geoCoordinates, options: reverseGeocodingOptions) { error, places in

                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: places ?? [])
                }
            }
        }

    }

    /// Performs an async request to search for plances based on given keyword.
    /// - Parameters:
    ///   - keyword: keyword to search
    ///   - geo: a GeoCoordinates
    ///   - max: maximum query output
    /// - Returns: return a List of places up to `max` places.
    func getAddresses(from keyword: String, near geo: GeoCoordinates, max: Int32 = 30) async throws -> [Place] {
        let queryArea = TextQuery.Area(areaCenter: geo)
        let textQuery = TextQuery(keyword, area: queryArea)
        let searchOptions = SearchOptions(languageCode: LanguageCode.enUs,
                                          maxItems: max)

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[Place], Error>) in
            searchEngine?.search(textQuery: textQuery,
                                options: searchOptions) { error, places in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: places ?? [])
                }
            }
        }
    }
}

extension RoutingError: Error {}
extension SearchError: Error {}
