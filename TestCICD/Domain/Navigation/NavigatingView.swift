//
//  NavigatingView.swift
//  EVP4
//
//  Created by Stone Zhang on 8/12/22.
//

import SwiftUI

struct NavigatingView: View {
    let action: NavigatingAction?

    var body: some View {
        VStack {
            Spacer()
            Text("Navigation has started on Meter")
            Spacer()
            Button("End Trip") {
                self.action?.endTrip()
            }
            Spacer()
        }
    }
}

class NavigatingViewState: ViewState {}

extension UIViewController {
    static func navigating(store: AppStore) -> ViewController {
        let action = NavigatingAction(store: store)
        let viewState = NavigatingViewState()
        let view = NavigatingView(action: action)
        return ViewController(viewState: viewState) { view }
    }
}

struct NavigatingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigatingView(action: nil)
    }
}
