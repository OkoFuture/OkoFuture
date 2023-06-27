//
//  AppCoordinator.swift
//  Oko Future
//
//  Created by Денис Калинин on 27.06.23.
//

import Foundation
import UIKit

class AppCoordinator: Coordinator {
    
    private var window: UIWindow
    private let navigationController: UINavigationController
    var starterCoordinator: Coordinator?
    
    init(windowScene: UIWindowScene, navigationController: UINavigationController = UINavigationController()) {
        self.window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        self.navigationController = navigationController
        setupWindow(windowScene: windowScene)
        setupStarterCoordinator()
    }
    
    func setupWindow(windowScene: UIWindowScene) {
        self.window.windowScene = windowScene
        self.window.rootViewController = navigationController
        self.window.makeKeyAndVisible()
    }
    
    func setupStarterCoordinator() {
        starterCoordinator = FeatureCoordinator(navigationController: navigationController)
    }
    
    func start() {
        starterCoordinator?.start()
    }
}
