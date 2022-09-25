//
//  Router.swift
//  EVP4
//
//  Created by Stone Zhang on 7/26/22.
//

import Foundation
import UIKit

class Router {
    private let rootNavigationController: UINavigationController
    private var navigationControllers: [UINavigationController]

    var rootViewController: UIViewController { rootNavigationController }

    init() {
        rootNavigationController = UINavigationController()
        navigationControllers = [rootNavigationController]
    }

    func setRoot(_ viewController: UIViewController) {
        rootNavigationController.setViewControllers([viewController], animated: false)
        rootNavigationController.dismiss(animated: false)
        navigationControllers = [rootNavigationController]
    }

    func present(_ viewController: UIViewController) {
        let newNavigationController = UINavigationController(rootViewController: viewController)
        newNavigationController.modalPresentationStyle = .fullScreen
        navigationControllers.last?.present(newNavigationController, animated: true)
        navigationControllers.append(newNavigationController)
    }

    func dismiss() {
        navigationControllers.last?.dismiss(animated: true)
        navigationControllers.removeLast()
    }

    func viewState<T: ViewState>(_ type: T.Type) -> T? {
        navigationControllers
            .flatMap { $0.viewControllers }
            .compactMap { $0 as? ViewStatable }
            .compactMap { $0.viewState as? T }
            .first
    }

}
