//
//  ViewController.swift
//  EVP4
//
//  Created by Stone Zhang on 7/26/22.
//

import Foundation
import SwiftUI

class ViewController: UIHostingController<AnyView>, ViewStatable {
    let viewState: ViewState

    init<Content: View>(viewState: ViewState, content: () -> Content) {
        self.viewState = viewState
        let view = AnyView(content())
        super.init(rootView: view)
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: For now, make it as global setting, later we could add it in `ViewStatable`
        hideKeyboardWhenTappedAround()
    }

}

// TODO: Put it in the right file soon
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
