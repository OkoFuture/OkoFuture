//
//  SceneDelegate.swift
//  Oko Future
//
//  Created by Denis on 23.03.2023.
//

import UIKit
import FirebaseCore
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let userService = UserService()
        
        let navigate = UINavigationController()
        var startViewController: UIViewController? = nil
        
        if let user = userService.getUser() {
            
            switch user {
                
            case _ where (user.name != nil):
                startViewController = UploadSceneViewController()
            case _ where (user.password != nil):
                startViewController = ProfileSettingViewController()
            case _ where (user.email != nil):
                startViewController = PasswordViewController()
                
            case _ where user.logStatus == .logInWithApple:
                startViewController = ProfileSettingViewController()
            case _ where user.logStatus == .logInWithGoogle:
                startViewController = ProfileSettingViewController()
                
            case _ where user.logStatus == .logInWithEmail:
                startViewController = ProfileSettingViewController()
                
            default: startViewController = WelcomeViewController()
                break
            }
            
        } else {
            
            userService.createUser()
            startViewController = WelcomeViewController()
        }
        
        guard let startViewController = startViewController else { return }

        navigate.pushViewController(startViewController, animated: false)
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = navigate
        window?.makeKeyAndVisible()
    }

}

