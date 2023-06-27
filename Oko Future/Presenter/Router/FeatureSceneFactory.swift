//
//  FeatureSceneFactory.swift
//  Oko Future
//
//  Created by Денис Калинин on 27.06.23.
//

import Foundation
import UIKit

struct FeatureSceneFactory {
    
    static func makeWelcomeScene(delegate: WelcomeViewCoordinatorDelegate?) -> WelcomeViewController {
        let viewController = WelcomeViewController()
        let presenter = WelcomeViewPresenter(welcomeView: viewController)
        presenter.coordinatorDelegate = delegate
        viewController.presenter = presenter
        return viewController
    }
    
    static func makeLogInScene(delegate: LogInViewCoordinatorDelegate?, registrationService: RegistrationService, userService: UserService) -> LogInViewController {
        let viewController = LogInViewController()
        let presenter = LogInViewPresenter(logInView: viewController, regService: registrationService, userService: userService, coordinatorDelegate: delegate)
        presenter.coordinatorDelegate = delegate
        viewController.presenter = presenter
        return viewController
    }
    
    static func makeProfileSettingScene(delegate: ProfileSettingViewCoordinatorDelegate?, registrationService: RegistrationService, userService: UserService) -> ProfileSettingViewController {
        let viewController = ProfileSettingViewController()
        let presenter = ProfileSettingViewPresenter(profileSettingView: viewController, regService: registrationService, userService: userService)
        presenter.coordinatorDelegate = delegate
        viewController.presenter = presenter
        return viewController
    }
}
