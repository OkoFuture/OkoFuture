//
//  FeatureSceneFactory.swift
//  Oko Future
//
//  Created by Денис Калинин on 27.06.23.
//

import Foundation
import UIKit

struct FeatureSceneFactory {
    
    static func makeFirstScene(delegate: WelcomeViewCoordinatorDelegate?) -> WelcomeViewController {
        let viewController = WelcomeViewController()
        let presenter = WelcomeViewPresenter(welcomeView: viewController)
        presenter.coordinatorDelegate = delegate
        viewController.presenter = presenter
        return viewController
    }
    
    static func makeSecondScene(delegate: LogInViewCoordinatorDelegate?) -> LogInViewController {
        let viewController = LogInViewController()
        let regService = RegistrationService()
        let userService = UserService()
        let presenter = LogInViewPresenter(logInView: viewController, regService: regService, userService: userService, coordinatorDelegate: delegate)
        presenter.coordinatorDelegate = delegate
        viewController.presenter = presenter
        return viewController
    }
}
