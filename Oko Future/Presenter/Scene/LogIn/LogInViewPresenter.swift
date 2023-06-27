//
//  LogInViewPresenter.swift
//  Oko Future
//
//  Created by Денис Калинин on 27.06.23.
//

import Foundation
import UIKit

protocol LogInViewCoordinatorDelegate: AnyObject {
    func pushToProfileSettingViewController()
}

protocol LogInViewPresenterDelegate: AnyObject {
    func pushToProfileSettingViewController()
    
}

class LogInViewPresenter {
    
    let regService: RegistrationService
    let userService: UserService
    
    weak var coordinatorDelegate: LogInViewCoordinatorDelegate?
    
    init(regService: RegistrationService, userService: UserService, coordinatorDelegate: LogInViewCoordinatorDelegate?) {
        self.regService = regService
        self.userService = userService
        self.coordinatorDelegate = coordinatorDelegate
    }
    
}

extension LogInViewPresenter: LogInViewPresenterDelegate {
    func pushToProfileSettingViewController() {
        coordinatorDelegate?.pushToProfileSettingViewController()
    }
    
    
}
