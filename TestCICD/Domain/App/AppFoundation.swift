//
//  AppFoundation.swift
//  EVP4
//
//  Created by Stone Zhang on 7/26/22.
//

import Foundation

class AppFoundation {
    let config: Configuration
    let router: Router
    let locationManager: LocationManager
    let bluetoothService: BluetoothKit
    let navigator: Navigatable
    let userDefault: UserDefaults

    internal init(config: Configuration = Configuration(),
                  router: Router = Router(),
                  locationManager: LocationManager = LocationManager(),
                  bluetoothService: BluetoothKit = BluetoothKit(),
                  navigator: Navigatable? = nil,
                  userDefault: UserDefaults = UserDefaults.instance) {
        self.config = config
        self.router = router
        self.locationManager = locationManager
        self.bluetoothService = bluetoothService
        if let navigator = navigator {
            self.navigator = navigator
        } else {
            self.navigator = Navigator(credentialID: config.string(for: .hereSDKCredentialID),
                                       credentialSecret: config.string(for: .hereSDKCredentialSecret))
        }
        self.userDefault = userDefault
    }
}
