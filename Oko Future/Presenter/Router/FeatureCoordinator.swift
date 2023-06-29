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
    private let arView: ARView
    
    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
        self.registrationService = RegistrationService()
        self.userService = UserService()
        self.arView = ARView()
        
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func start() {
        
//        uploadLevelTwoScene()
//        showGeneralScene()
        uploadLevelOneScene()
        return
        
        if let user = userService.getUser() {

            switch user {

            case _ where (user.name != nil):
                showGeneralScene()
            case _ where (user.password != nil):
                showProfileSettingScene()
//            case _ where (user.email != nil):
//                startViewController = PasswordViewController()

            case _ where user.logStatus == .logInWithApple:
                showProfileSettingScene()
            case _ where user.logStatus == .logInWithGoogle:
                showProfileSettingScene()

            case _ where user.logStatus == .logInWithEmail:
                showProfileSettingScene()

            default: showWelcomeScene()
                break
            }

        } else {

            userService.createUser()
            showWelcomeScene()
        }
    }
    
    private func cleansingArView(complection: @escaping () -> Void) {
        
//        if self.arView.scene.anchors.isEmpty {
//            complection()
//        } else {
            self.arView.session.pause()
            self.arView.removeFromSuperview()
            self.arView.scene.anchors.removeAll()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                complection()
            })
//        }
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
    
    func uploadGeneralScene() {
        cleansingArView(complection: { [self] in
            let scene = FeatureSceneFactory.makeGeneralScene(delegate: self, arView: arView)
            navigationController.viewControllers = [scene]
        })
    }
    
    func uploadLevelOneScene() {
        cleansingArView(complection: { [self] in
            let scene = FeatureSceneFactory.makeLevelOneScene(delegate: self, arView: arView)
            navigationController.viewControllers = [scene]
        })
    }
    
    func uploadLevelTwoScene() {
        cleansingArView(complection: { [self] in
            let scene = FeatureSceneFactory.makeLevelTwoScene(delegate: self, arView: arView)
            navigationController.viewControllers = [scene]
        })
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

extension FeatureCoordinator: ProfileSettingViewCoordinatorDelegate, LevelTwoViewCoordinatorDelegate, LevelOneViewCoordinatorDelegate {
    func showGeneralScene() {
        uploadGeneralScene()
    }
}

extension FeatureCoordinator: GeneralSceneViewCoordinatorDelegate {
    func showLevelTwoScene() {
        uploadLevelTwoScene()
    }
    
    func showLevelOneScene() {
        uploadLevelOneScene()
    }
    
    func showUserProfileView() {
//        showUserProfileSettingScene()
    }
    
}
