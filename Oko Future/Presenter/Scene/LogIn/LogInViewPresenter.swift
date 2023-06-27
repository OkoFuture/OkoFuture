//
//  LogInViewPresenter.swift
//  Oko Future
//
//  Created by Денис Калинин on 27.06.23.
//

import UIKit
import AuthenticationServices
import Firebase
import GoogleSignIn
import FirebaseDatabase
import MessageUI

protocol LogInViewCoordinatorDelegate: AnyObject {
    func pushToProfileSettingViewController()
}

protocol LogInViewPresenterDelegate: AnyObject {
    func tapLogInApple(delegate: ASAuthorizationControllerDelegate, presentationContextProvider: ASAuthorizationControllerPresentationContextProviding)
    func pushToProfileSettingViewController()
    func tapSendButton()
    func tapLogInGoogle(completionHandler: @escaping (() -> Void))
    func didCompleteWithAuthorizationApple(authorization: ASAuthorization)
    func signInEmail(withEmail: String, password: String, completionHandler: @escaping (() -> Void))
    func checkUser()
}

class LogInViewPresenter {
    
    let regService: RegistrationService
    let userService: UserService
    
    weak var coordinatorDelegate: LogInViewCoordinatorDelegate?
    
    private var currentNonce: String?
    
    init(regService: RegistrationService, userService: UserService, coordinatorDelegate: LogInViewCoordinatorDelegate?) {
        self.regService = regService
        self.userService = userService
        self.coordinatorDelegate = coordinatorDelegate
    }
    
}

extension LogInViewPresenter: LogInViewPresenterDelegate {
    func checkUser() {
        if userService.getUser() == nil {
            regService.createUser()
        }
    }
    
    func signInEmail(withEmail: String, password: String, completionHandler: @escaping (() -> Void)) {
        regService.signInEmail(withEmail: withEmail, password: password, completionHandler: completionHandler)
    }
    
    
    func didCompleteWithAuthorizationApple(authorization: ASAuthorization) {
        
        switch authorization.credential {
            
        case let credentials as ASAuthorizationAppleIDCredential:
            
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                
                let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                               rawNonce: nonce,
                                                               fullName: appleIDCredential.fullName)
                
                Auth.auth().signIn(with: credential) { [unowned self] (_, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        if let firstName = appleIDCredential.fullName?.givenName, let lastName = appleIDCredential.fullName?.familyName, let email = appleIDCredential.email {
                            for userDate in UserData.allCases {
                                switch userDate {
                                case .name:
                                    regService.updateUserData(typeUserData: .name, userData: firstName + " " + lastName, needUpdateFirebase: false)
                                case .email:
                                    regService.updateUserData(typeUserData: .email, userData: email, needUpdateFirebase: false)
                                default: break
                                }
                            }
                        }
                        
                        print ("log in with apple completed", appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName)
                        
                        userService.updateUserLogStatus(logStatus: .logInWithApple)
                        pushToProfileSettingViewController()
                    }
                }
            }
        default:
            break
        }
    }
    
    func tapSendButton() {
        
    }
    
    func tapLogInGoogle(completionHandler: @escaping (() -> Void)) {
        regService.signIn(completionHandler: completionHandler)
    }
    
    func pushToProfileSettingViewController() {
        coordinatorDelegate?.pushToProfileSettingViewController()
    }
    
    func tapLogInApple(delegate: ASAuthorizationControllerDelegate, presentationContextProvider: ASAuthorizationControllerPresentationContextProviding) {
        currentNonce = regService.tapLogInApple(delegate: delegate, presentationContextProvider: presentationContextProvider)
    }
    
}
