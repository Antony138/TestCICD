//
//  AppStore.swift
//  EVP4
//
//  Created by Stone Zhang on 7/25/22.
//

import Foundation
import Combine
import UIKit

class AppStore {
    let state: AppState = AppState()
    let foundation: AppFoundation

    init(foundation: AppFoundation = AppFoundation()) {
        self.foundation = foundation
        foundation.router.setRoot(.routePlanning(store: self))
    }

}
