//
//  FeatureSceneFactory.swift
//  Oko Future
//
//  Created by Денис Калинин on 27.06.23.
//

import Foundation
import UIKit
import RealityKit

struct FeatureSceneFactory {
    
    static func makeWelcomeScene(delegate: WelcomeViewCoordinatorDelegate?) -> WelcomeViewController {
        let viewController = WelcomeViewController()
        let presenter = WelcomeViewPresenter(welcomeView: viewController)
        presenter.coordinatorDelegate = delegate
        viewController.presenter = presenter
        return viewController
    }
    
    static func makeLogInScene(delegate: LogInViewCoordinatorDelegate, registrationService: RegistrationService, userService: UserService) -> LogInViewController {
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
    
    static func makeLevelOneScene(delegate: LevelOneViewCoordinatorDelegate, arView: ARView) -> LevelOneViewController {
        let viewController = LevelOneViewController()
        let presenter = LevelOneViewPresenter(view: viewController, arView: arView, coordinatorDelegate: delegate)
        viewController.presenter = presenter
        viewController.arView = presenter.arView
        return viewController
    }
    
    static func makeLevelTwoScene(delegate: LevelTwoViewCoordinatorDelegate, arView: ARView) -> LevelTwoViewController {
        let viewController = LevelTwoViewController()
        let presenter = LevelTwoViewPresenter(view: viewController, arView: arView, coordinatorDelegate: delegate)
        viewController.presenter = presenter
        viewController.arView = presenter.arView
        return viewController
    }
    
    static func makeGeneralScene(delegate: GeneralSceneViewCoordinatorDelegate, arView: ARView) -> GeneralViewController {
        let viewController = GeneralViewController()
        let presenter = GeneralScenePresenter(view: viewController, arView: arView, coordinatorDelegate: delegate)
        viewController.presenter = presenter
        viewController.arView = presenter.arView
        return viewController
    }
    
    static func makeUserProfileScene(delegate: UserProfileViewCoordinatorDelegate, registrationService: RegistrationService, userService: UserService) -> UserProfileViewController {
        let viewController = UserProfileViewController()
        let presenter = UserProfileViewPresenter(userProfileView: viewController, regService: registrationService, userService: userService, coordinatorDelegate: delegate)
        presenter.coordinatorDelegate = delegate
        viewController.presenter = presenter
        return viewController
    }
}
