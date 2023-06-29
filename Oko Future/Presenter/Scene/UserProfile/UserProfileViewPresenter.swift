//
//  UserProfileViewPresenter.swift
//  Oko Future
//
//  Created by Денис Калинин on 29.06.23.
//

import UIKit
import AuthenticationServices
import Firebase

protocol UserProfileViewCoordinatorDelegate: AnyObject {
    func backToGeneralScene()
    func backToWelcomeScene()
}

protocol UserProfileViewPresenterDelegate: AnyObject {
    func returnNameUser() -> String
    func logOut(viewForError: UIViewController, delegate: ASAuthorizationControllerDelegate, presentationContextProvider: ASAuthorizationControllerPresentationContextProviding)
    func deleteUser(viewForError: UIViewController, delegate: ASAuthorizationControllerDelegate, presentationContextProvider: ASAuthorizationControllerPresentationContextProviding)
    func backToGeneralScene()
    func didCompleteWithAuthorization(authorization: ASAuthorization)
}

final class UserProfileViewPresenter: NSObject {
    
    let userProfileView: UserProfileViewProtocol
    
    let regService: RegistrationService
    let userService: UserService
    
    weak var coordinatorDelegate: UserProfileViewCoordinatorDelegate!
    
    private var currentNonce: String?
    
    init(userProfileView: UserProfileViewProtocol, regService: RegistrationService, userService: UserService, coordinatorDelegate: UserProfileViewCoordinatorDelegate) {
        self.userProfileView = userProfileView
        self.regService = regService
        self.userService = userService
        self.coordinatorDelegate = coordinatorDelegate
    }
    
}

extension UserProfileViewPresenter: UserProfileViewPresenterDelegate {
    
    func backToGeneralScene() {
        coordinatorDelegate.backToGeneralScene()
    }
    
    func deleteUser(viewForError: UIViewController, delegate: ASAuthorizationControllerDelegate, presentationContextProvider: ASAuthorizationControllerPresentationContextProviding) {
        currentNonce = regService.deleteUser(viewForError: viewForError, delegate: delegate, presentationContextProvider: presentationContextProvider) { [weak self] in
            guard let self = self else { return }
            coordinatorDelegate.backToWelcomeScene()
        }
    }
    
    
    func logOut(viewForError: UIViewController, delegate: ASAuthorizationControllerDelegate, presentationContextProvider: ASAuthorizationControllerPresentationContextProviding) {
        regService.logOut(viewForError: viewForError, delegate: delegate, presentationContextProvider: presentationContextProvider)
        coordinatorDelegate.backToWelcomeScene()
    }
    
    func returnNameUser() -> String {
        guard let user = userService.getUser() else {
            return "username unknown"
        }
        
        if let name = user.name {
            return name
        } else {
            return "username unknown"
        }
    }
    
    func didCompleteWithAuthorization(authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential
        else {
          print("Unable to retrieve AppleIDCredential")
          return
        }

          guard let _ = currentNonce else {
          fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }

        guard let appleAuthCode = appleIDCredential.authorizationCode else {
          print("Unable to fetch authorization code")
          return
        }

        guard let authCodeString = String(data: appleAuthCode, encoding: .utf8) else {
          print("Unable to serialize auth code string from data: \(appleAuthCode.debugDescription)")
          return
        }

        Task {
          do {
            try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
              try await Auth.auth().currentUser?.delete()
              coordinatorDelegate.backToWelcomeScene()
          } catch {
              print ("delete user Apple fail, error =", error.localizedDescription)
          }
        }
    }
    
    
}

