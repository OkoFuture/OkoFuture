//
//  FeatureCoordinator.swift
//  Oko Future
//
//  Created by Денис Калинин on 27.06.23.
//

import UIKit
import ARKit
import RealityKit

class FeatureCoordinator: Coordinator {

    private let navigationController: UINavigationController
    private let registrationService: RegistrationService
    private let userService: UserService
    
    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
        self.registrationService = RegistrationService()
        self.userService = UserService()
    }
    
    func start() {
        
        if let user = userService.getUser() {

            switch user {

//            case _ where (user.name != nil):
//                startViewController = UploadSceneViewController()
//            case _ where (user.password != nil):
//                startViewController = ProfileSettingViewController()
//            case _ where (user.email != nil):
//                startViewController = PasswordViewController()
//
//            case _ where user.logStatus == .logInWithApple:
//                startViewController = ProfileSettingViewController()
//            case _ where user.logStatus == .logInWithGoogle:
//                startViewController = ProfileSettingViewController()
//
//            case _ where user.logStatus == .logInWithEmail:
//                startViewController = ProfileSettingViewController()

            default: showWelcomeScene()
                break
            }

        } else {

            userService.createUser()
            showWelcomeScene()
        }
    }
}

extension FeatureCoordinator {
    
    func showWelcomeScene() {
        let scene = FeatureSceneFactory.makeWelcomeScene(delegate: self)
        navigationController.viewControllers = [scene]
    }
    
    func showLogInScene() {
        let scene = FeatureSceneFactory.makeLogInScene(delegate: self, registrationService: registrationService, userService: userService)
        navigationController.pushViewController(scene, animated: true)
    }
    
    func showProfileSettingScene() {
        let scene = FeatureSceneFactory.makeProfileSettingScene(delegate: self, registrationService: registrationService, userService: userService)
        navigationController.pushViewController(scene, animated: true)
    }
    
    func uploadLevelTwoScene() {
        let arView = ARView()
        let scene = FeatureSceneFactory.makeLevelTwoScene(delegate: self, arView: arView)
        navigationController.viewControllers = [scene]
    }
    
}

extension FeatureCoordinator: WelcomeViewCoordinatorDelegate {
    
    func tapStartButton() {
        showLogInScene()
    }
}

extension FeatureCoordinator: LogInViewCoordinatorDelegate {
    func pushToProfileSettingViewController() {
        showProfileSettingScene()
    }
}

extension FeatureCoordinator: ProfileSettingViewCoordinatorDelegate {
    func uploadGeneralView() {
        uploadLevelTwoScene()
    }
}

extension FeatureCoordinator: LevelTwoViewCoordinatorDelegate {
    func showLevelTwoScene() {
//        uploadLevelTwoScene()
    }
}
