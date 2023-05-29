//
//  SceneDelegate.swift
//  Oko Future
//
//  Created by Denis on 23.03.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let navigate = UINavigationController()
        let welcomeVC = WelcomeViewController()
        navigate.pushViewController(welcomeVC, animated: false)
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = navigate
        window?.makeKeyAndVisible()
    }

}

