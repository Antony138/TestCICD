//
//  LocationManager.swift
//  EVP4
//
//  Created by Stone Zhang on 7/28/22.
//

import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject {
    private let manager: CLLocationManager = CLLocationManager()
    // Authorization
    var locationServicesEnabled: Bool { CLLocationManager.locationServicesEnabled() }
    private let authorizationStatusSubject: CurrentValueSubject<CLAuthorizationStatus, Never>
    private let accuracyAuthorizationSubject: CurrentValueSubject<CLAccuracyAuthorization, Never>
    lazy var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> = authorizationStatusSubject.eraseToAnyPublisher()
    lazy var accuracyAuthorizationPublisher: AnyPublisher<CLAccuracyAuthorization, Never> = accuracyAuthorizationSubject.eraseToAnyPublisher()
    // Location
    private let locationSubject: CurrentValueSubject<CLLocation?, Never>
    private let isLocationUpdatesPausedSubject: CurrentValueSubject<Bool, Never>
    lazy var locationPublisher: AnyPublisher<CLLocation?, Never> = locationSubject.eraseToAnyPublisher()
    lazy var isLocationUpdatesPausedPublisher: AnyPublisher<Bool, Never> = isLocationUpdatesPausedSubject.eraseToAnyPublisher()
    // Error
    private let errorSubject: PassthroughSubject<Error, Never> = PassthroughSubject()
    lazy var errorPublisher: AnyPublisher<Error, Never> = errorSubject.eraseToAnyPublisher()

    override init() {
        authorizationStatusSubject = CurrentValueSubject(manager.authorizationStatus)
        accuracyAuthorizationSubject = CurrentValueSubject(manager.accuracyAuthorization)
        locationSubject = CurrentValueSubject(manager.location)
        isLocationUpdatesPausedSubject = CurrentValueSubject(manager.pausesLocationUpdatesAutomatically)
        super.init()
        manager.delegate = self
    }

    // MARK: Requesting Authorization for Location Services

    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func requestAlwaysAuthorization() {
        manager.requestAlwaysAuthorization()
    }

    // MARK: Initiating Standard Location Updates

    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }

    func pauseUpdatingLocation() {
        manager.pausesLocationUpdatesAutomatically = true
    }

    func resumeUpdatingLocation() {
        manager.pausesLocationUpdatesAutomatically = false
    }

    var allowsBackgroundLocationUpdates: Bool {
        get { manager.allowsBackgroundLocationUpdates }
        set { manager.allowsBackgroundLocationUpdates = newValue }
    }

    var showsBackgroundLocationIndicator: Bool {
        get { manager.showsBackgroundLocationIndicator }
        set { manager.showsBackgroundLocationIndicator = newValue }
    }

    var activityType: CLActivityType {
        get { manager.activityType }
        set { manager.activityType = newValue }
    }

    // MARK: Specifying Distance and Accuracy

    var distanceFilter: CLLocationDistance {
        get { manager.distanceFilter }
        set { manager.distanceFilter = newValue }
    }

    var desiredAccuracy: CLLocationAccuracy {
        get { manager.desiredAccuracy }
        set { manager.desiredAccuracy = newValue }
    }

}

extension LocationManager: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatusSubject.send(manager.authorizationStatus)
        accuracyAuthorizationSubject.send(manager.accuracyAuthorization)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationSubject.send(locations.first)
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        isLocationUpdatesPausedSubject.send(true)
    }

    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        isLocationUpdatesPausedSubject.send(false)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorSubject.send(error)
    }

}
