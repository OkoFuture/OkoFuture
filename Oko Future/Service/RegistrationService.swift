//
//  RegistrationService.swift
//  Oko Future
//
//  Created by Денис Калинин on 26.06.23.
//

import UIKit
import Firebase
import AuthenticationServices
import CryptoKit
import GoogleSignIn

final class RegistrationService {
    
    let userService = UserService()
    
    func signIn(view: UIViewController,completionHandler: @escaping (() -> Void)) {
        
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                self.authenticateUser(view: view, for: user, with: error, completionHandler: completionHandler)
            }
        } else {
            
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            
            let configuration = GIDConfiguration(clientID: clientID)
            
            GIDSignIn.sharedInstance.configuration = configuration
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
            
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController, hint: nil, completion: { [unowned self] result, error in
                self.authenticateUser(view: view, for: result?.user, with: error, completionHandler: completionHandler)
            })
        }
    }
    
    private func authenticateUser(view: ShowAlertProtocol , for user: GIDGoogleUser?, with error: Error?, completionHandler: @escaping (() -> Void)) {
        let loader = view.defaultLoader()
        
        if let error = error {
            view.stopDefaultLoader(loader: loader)
            view.showAlert(title: nil, message: error.localizedDescription, complection: nil)
                
            return
        }
        
        guard let accessToken = user?.accessToken, let idToken = user?.idToken else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
        
        Auth.auth().signIn(with: credential) { [weak self] (_, error) in
            if let error = error {
                view.showAlert(title: nil, message: error.localizedDescription, complection: nil)
            } else {
                
                guard let self = self else { return }
                
                if let fullname = user?.profile?.name, let email = user?.profile?.email {
                    for userDate in UserData.allCases {
                        switch userDate {
                        case .name:
                            self.updateUserData(typeUserData: .name, userData: fullname, needUpdateFirebase: false)
                        case .email:
                            self.updateUserData(typeUserData: .email, userData: email, needUpdateFirebase: false)
                        default: break
                        }
                    }
                }
                view.stopDefaultLoader(loader: loader)
                print ("log in with google completed", user?.profile?.email, user?.profile?.name, user?.profile?.givenName, user?.profile?.familyName, user?.profile?.imageURL(withDimension: 320))
                
                userService.updateUserLogStatus(logStatus: .logInWithGoogle)
                completionHandler()
            }
        }
    }
    
    public func signInEmail(view: ShowAlertProtocol, withEmail: String, password: String, completionHandler: @escaping (() -> Void)) {
        let loader = view.defaultLoader()
        Auth.auth().signIn(withEmail: withEmail, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
          
            if let error = error {
                print ("signInEmail fail error =", error.localizedDescription)
                
                if error.localizedDescription == "The password is invalid or the user does not have a password." {
                    view.stopDefaultLoader(loader: loader)
                    view.showAlert(title: nil, message: error.localizedDescription, complection: nil)
                    return
                }
                
                strongSelf.addUserFirebase(email: withEmail, password: password, completedHangler: { [weak self] error in
                    
                    if let error = error {
                        view.stopDefaultLoader(loader: loader)
                        view.showAlert(title: nil, message: error.localizedDescription, complection: nil)
                    } else {
                        guard let self = self else { return }
                        view.stopDefaultLoader(loader: loader)
                        view.showAlert(title: nil, message: "User created successfully", complection: {
                            self.userService.updateUserLogStatus(logStatus: .logInWithEmail)
                            completionHandler()
                        })
                    }
                    
                })
            } else {
                view.stopDefaultLoader(loader: loader)
                strongSelf.userService.updateUserLogStatus(logStatus: .logInWithEmail)
                completionHandler()
            }
        }
    }
    
    private func deleteUserFirebase(viewForError: UIViewController ,completionHandler: @escaping (() -> Void)) {
        guard let user = Auth.auth().currentUser else { return }
        
        user.delete(completion: { error in
            if let error = error {
                let action = UIAlertAction(title: "Close", style: .cancel)
//                self.showAlert(title: "Error", message: "Failed to delete account", view: viewForError, actions: [action])
            } else {
                completionHandler()
            }
        })
    }
    
    @available(iOS 13, *)
    func tapLogInApple(delegate: ASAuthorizationControllerDelegate, presentationContextProvider: ASAuthorizationControllerPresentationContextProviding) -> String {
        let nonce = randomNonceString()
//        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = delegate
        authorizationController.presentationContextProvider = presentationContextProvider
        authorizationController.performRequests()
        
        return nonce
    }
    
    public func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    @available(iOS 13, *)
    public func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func deleteUserApple(delegate: ASAuthorizationControllerDelegate,presentationContextProvider: ASAuthorizationControllerPresentationContextProviding) -> String {
        do {
//            let nonce = try randomNonceString()
            let nonce = randomNonceString()
//            currentNonce = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = delegate
            authorizationController.presentationContextProvider = presentationContextProvider
            authorizationController.performRequests()
            
            return nonce
        } catch {
            print ("delete user Apple error =", error.localizedDescription)
//            let action = UIAlertAction(title: "Close", style: .cancel)
//            self.showAlert(title: "Error", message: "Failed to delete account", view: viewForError, actions: [action])
        }
    }
    
    public func deleteUser(viewForError: UIViewController, delegate: ASAuthorizationControllerDelegate, presentationContextProvider: ASAuthorizationControllerPresentationContextProviding, completionHandler: @escaping () -> Void) -> String? {
        guard let user = userService.getUser() else { return nil}
        
        var currentNonce: String? = nil
        
        deleteUserFirebase(viewForError: viewForError, completionHandler: completionHandler)
        userService.deleteUserUserDefaults()
        
        return currentNonce
    }
    
    
    public func logOut(viewForError: UIViewController, delegate: ASAuthorizationControllerDelegate,presentationContextProvider: ASAuthorizationControllerPresentationContextProviding) {
        
        guard let user = userService.getUser() else { return }
        
//        switch user.logStatus {
//
//        case .logInWithApple:
//            deleteUserApple(delegate: delegate, presentationContextProvider: presentationContextProvider)
//        default: break
//        }
        
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
            let action = UIAlertAction(title: "Close", style: .cancel)
//            self.showAlert(title: "Error", message: "Failed to log out account", view: viewForError, actions: [action])
        }
        
        userService.deleteUserUserDefaults()
    }
    
    public func createUser() {
        userService.setUser(user: User())
    }
    
    public func updateUserData(typeUserData: UserData, userData: String, needUpdateFirebase: Bool) {
        
        guard let user = userService.getUser() else { return }
        
        switch typeUserData {
            
        case .name:
            user.name = userData
        case .email:
            user.email = userData
        case .password:
            user.password = userData
        }
        
        userService.setUser(user: user)
        
        if needUpdateFirebase {
            updateUserFirebase(user: user)
        }
    }
    
    public func addUserFirebase(email: String, password: String, completedHangler: @escaping ((Error?) -> Void)) {
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error == nil {
                
                self.updateUserData(typeUserData: .password, userData: password, needUpdateFirebase: false)
                self.updateUserData(typeUserData: .email, userData: email, needUpdateFirebase: false)
                completedHangler(nil)
            } else {
                print ("createUser is fail", error?.localizedDescription)
                completedHangler(error)
            }
        }
    }
    
    private func updateUserFirebase(user: User) {
        guard let userFire: FirebaseAuth.User = Auth.auth().currentUser else { return }
        
        if let userEmail = user.email {
            userFire.updateEmail(to: userEmail)
        }
        
        if let userPassword = user.password {
            userFire.updatePassword(to: userPassword)
        }
        
        if let userName = user.name {
            let changeRequest = userFire.createProfileChangeRequest()
            changeRequest.displayName = userName
            
            changeRequest.commitChanges { error in
                // ...
            }
        }
        
        if let urlPhoto = user.imageProfile {
            let changeRequest = userFire.createProfileChangeRequest()
            changeRequest.photoURL = urlPhoto
            
            changeRequest.commitChanges { error in
                // ...
            }
        }
        
        Auth.auth().updateCurrentUser(userFire)
    }
    
}
