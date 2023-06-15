//
//  Helper.swift
//  Oko Future
//
//  Created by Денис Калинин on 24.04.23.
//

import UIKit
import Firebase
import AuthenticationServices
import CryptoKit

final class Helper {
    
    static var app: Helper = {
        return Helper()
    }()
    
    public func createUser() {
        Helper().setUser(user: User())
    }
    
    public func addUserFirebase(email: String, password: String, completedHangler: @escaping (() -> Void)) {
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if error == nil {
                
                Helper().updateUserData(typeUserData: .password, userData: password, needUpdateFirebase: false)
                Helper().updateUserData(typeUserData: .email, userData: email, needUpdateFirebase: false)
                completedHangler()
            } else {
                print ("createUser is fail", error?.localizedDescription)
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
    
    public func setUser(user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "user")
        }
    }
    
    public func getUser() -> User? {
        guard let data = UserDefaults.standard.object(forKey: "user") as? Data else { return nil }
        guard let user = try? JSONDecoder().decode(User.self, from: data) else { return nil }
        return user
    }
    
    public func passwordСheck(password: String) -> Bool {
        guard let user = getUser() else { return false }
        
        if user.password == password{
            return true
        } else {
            return false
        }
    }
    
    public func userСheck() -> Bool {
        
        if let _ = getUser() {
            return true
        } else {
            return false
        }
    }
    
    public func returnUserLogStatus() -> UserLogStatus? {
        guard let user = getUser() else { return nil }
        
        return user.logStatus
    }
    
    public func updateUserData(typeUserData: UserData, userData: String, needUpdateFirebase: Bool) {
        
        guard let user = getUser() else { return }
        
        switch typeUserData {
            
        case .name:
            user.name = userData
        case .email:
            user.email = userData
        case .password:
            user.password = userData
        }
        
        setUser(user: user)
        
        if needUpdateFirebase {
            updateUserFirebase(user: user)
        }
    }
    
    public func updateUserLogStatus(logStatus: UserLogStatus) {
        guard let user = getUser() else { return }
        
        user.logStatus = logStatus
        
        setUser(user: user)
    }
    
    private func deleteUser() {
        
        UserDefaults.standard.removeObject(forKey: "user")
    }
    
    public func deleteUserFirebase() {
        guard let user = Auth.auth().currentUser else { return }
        
        user.delete(completion: { error in
            if let error = error {
                
            } else {
                
            }
        })
    }
    
//    public func deleteUserApple() {
//          do {
//            let nonce = try CryptoUtils.randomNonceString()
//            currentNonce = nonce
//            let appleIDProvider = ASAuthorizationAppleIDProvider()
//            let request = appleIDProvider.createRequest()
//            request.requestedScopes = [.fullName, .email]
//            request.nonce = CryptoUtils.sha256(nonce)
//
//            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//            authorizationController.delegate = self
//            authorizationController.presentationContextProvider = self
//            authorizationController.performRequests()
//          } catch {
//            // In the unlikely case that nonce generation fails, show error view.
//            displayError(error)
//          }
//    }
    
    public func reauthenticateUser() {
        let user = Auth.auth().currentUser
        var credential: AuthCredential
       
        // Prompt the user to re-provide their sign-in credentials

//        user?.reauthenticate(with: credential) { result, error  in
//          if let error = error {
//            // An error happened.
//          } else {
//            // User re-authenticated.
//          }
//        }
        
        /// apple
//        let credential = OAuthProvider.credential(
//          withProviderID: "apple.com",
//          IDToken: appleIdToken,
//          rawNonce: rawNonce
//        )
//        // Reauthenticate current Apple user with fresh Apple credential.
//        Auth.auth().currentUser.reauthenticate(with: credential) { (authResult, error) in
//          guard error != nil else { return }
//          // Apple user successfully re-authenticated.
//          // ...
//        }
    }
    
    public func logOut() {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        
        deleteUser()
    }
    
    public func arrayNameAvatarUSDZ() -> [String] {
        ["avtr_anim_0805.usdz", "avtr_anim_0805.usdz"]
    }
    
    public func fontChakra500(size: CGFloat) -> UIFont? {
        return UIFont(name:"ChakraPetch-Medium", size: size)
    }
    
    public func fontChakra600(size: CGFloat) -> UIFont? {
        return UIFont(name:"ChakraPetch-SemiBold", size: size)
    }
    
    public func backgroundColor() -> UIColor {
        return UIColor.black.withAlphaComponent(0.32)
    }
    
    public func borderColor() -> CGColor {
        return UIColor.black.withAlphaComponent(0.04).cgColor
    }
}
