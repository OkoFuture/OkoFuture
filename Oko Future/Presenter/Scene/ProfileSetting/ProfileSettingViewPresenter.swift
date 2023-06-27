//
//  ProfileSettingViewPresenter.swift
//  Oko Future
//
//  Created by Денис Калинин on 27.06.23.
//

import Foundation
import UIKit

protocol ProfileSettingViewCoordinatorDelegate: AnyObject {
    func uploadGeneralView()
}

protocol ProfileSettingViewPresenterDelegate: AnyObject {
    func returnUserName() -> String
    func tapSaveStartButton(name: String)
}

class ProfileSettingViewPresenter {
    
    let profileSettingView: ProfileSettingViewProtocol
    
    let regService: RegistrationService
    let userService: UserService
    
    weak var coordinatorDelegate: ProfileSettingViewCoordinatorDelegate?
    
    init(profileSettingView: ProfileSettingViewProtocol, regService: RegistrationService, userService: UserService) {
        self.profileSettingView = profileSettingView
        self.regService = regService
        self.userService = userService
    }
    
}

extension ProfileSettingViewPresenter: ProfileSettingViewPresenterDelegate {
    func tapSaveStartButton(name: String) {
        regService.updateUserData(typeUserData: .name, userData: name, needUpdateFirebase: true)
        coordinatorDelegate?.uploadGeneralView()
    }
    
    func returnUserName() -> String {
        guard let name = userService.getUser()?.name else { return ""}
        return name
    }
    
}
