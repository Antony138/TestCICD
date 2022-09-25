//
//  RoutePlanningView.swift
//  EVP4
//
//  Created by Stone Zhang on 8/25/22.
//

import SwiftUI
import heresdk

struct RoutePlanningView: View {
    @EnvironmentObject var viewState: RoutePlanningViewState
    let action: RoutePlanningAction?

    var body: some View {
        VStack {
            SearchBar(viewState: viewState.searchBarViewState)
            ZStack {
                HEREMapView(viewState: viewState.mapViewState,
                            didLongPressCoordinates: { action?.do(.selectDestinationByLongpress($0)) },
                            didTapRoute: { action?.do(.selectRoute($0)) })
                .onAppear {
                    action?.do(.showMotorcyclePin)
                }
                .ignoresSafeArea(.keyboard)

                switch viewState.detailInfoState {
                case .show, .showRouteInfo, .showManeuverInfo:
                    VStack {
                        Spacer()
                        DetailInfoView(state: viewState.detailInfoState,
                                       onTapDirection: { action?.do(.selectDestination($0)) },
                                       onTapViewRoute: { action?.do(.viewRoute($0)) },
                                       onTapSendToMeter: { _ in action?.do(.showOption) },
                                       onTapBack: { action?.do(.selectSearchResult($0)) },
                                       onTapFav: { action?.do(.toggleFav($0)) })
                    }
                    .confirmationDialog("Choose sharing method",
                                        isPresented: $viewState.isShowingOptions) {
                        Button("Geo coordinates") {
                            action?.do(.shareRoute(.geoCoordinates))
                                }
                        Button("Serialized place object") {
                            action?.do(.shareRoute(.place))
                                }
                        Button("GPX trace") {
                            action?.do(.shareRoute(.gpxTrace))
                                }
                        Button("Route handle") {
                            action?.do(.shareRoute(.routeHandle))
                                }
                    }
                default:
                    EmptyView()
                }

                if let result = viewState.searchResult, !viewState.isSearchResultHidden {
                    SearchResultView(result: result) { place in
                        action?.do(.selectSearchResult(place))
                    }
                }
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

extension UIViewController {
    static func routePlanning(store: AppStore) -> ViewController {
        let action = RoutePlanningAction(store: store)
        let viewState = RoutePlanningViewState(state: store.state, action: action)
        let view = RoutePlanningView(action: action).environmentObject(viewState)
        return ViewController(viewState: viewState) { view }
    }
}

struct RoutePlanningView_Previews: PreviewProvider {
    static var previews: some View {
        let viewState = RoutePlanningViewState(state: AppState(), action: nil)
        RoutePlanningView(action: nil).environmentObject(viewState)
    }
}
