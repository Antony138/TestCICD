//
//  NavigatingAction.swift
//  EVP4
//
//  Created by Stone Zhang on 8/12/22.
//

import Foundation

class NavigatingAction {
    private let store: AppStore

    private var routePlanningViewState: RoutePlanningViewState {
        guard let viewState = store.foundation.router.viewState(RoutePlanningViewState.self) else {
            fatalError("RoutePlanningViewState not found")
        }
        return viewState
    }

    init(store: AppStore) {
        self.store = store
    }

    func endTrip() {
        store.foundation.router.dismiss()
        // FIXME: Is it idle state?
        routePlanningViewState.mapViewState.destinationPlace = nil
        routePlanningViewState.mapViewState.selectedRouteIndex = nil
        routePlanningViewState.mapViewState.routes = []
    }

}
