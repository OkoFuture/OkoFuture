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
import GoogleSignIn

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
    
    private func deleteUserUserDefaults() {
        
        UserDefaults.standard.removeObject(forKey: "user")
    }
    
    private func deleteUserFirebase(completionHandler: @escaping (() -> Void)) {
        guard let user = Auth.auth().currentUser else { return }
        
        user.delete(completion: { error in
            if let error = error {
                
            } else {
                completionHandler()
            }
        })
    }
    
    @available(iOS 13, *)
    func tapLogInApple(delegate: ASAuthorizationControllerDelegate, presentationContextProvider: ASAuthorizationControllerPresentationContextProviding) -> String {
        let nonce = Helper().randomNonceString()
//        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = Helper().sha256(nonce)
        
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
            let nonce = Helper().randomNonceString()
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
        }
    }
    
    public func deleteUser(delegate: ASAuthorizationControllerDelegate, presentationContextProvider: ASAuthorizationControllerPresentationContextProviding, completionHandler: @escaping () -> Void) -> String? {
        guard let user = getUser() else { return nil}
        
        var currentNonce: String? = nil
        
//        switch user.logStatus {
//
//        case .logInWithApple:
//            currentNonce = deleteUserApple(delegate: delegate, presentationContextProvider: presentationContextProvider)
//        case _ where user.logStatus == .logInWithGoogle || user.logStatus == .logInWithEmail:
//            deleteUserFirebase(completionHandler: completionHandler)
//        default: break
//        }
        deleteUserFirebase(completionHandler: completionHandler)
        self.deleteUserUserDefaults()
        
        return currentNonce
    }
    
    /// надо разбить по частям и доделать
//    public func reauthenticateUser(authorization: ASAuthorization) {
//        guard let userStatus = getUser()?.logStatus else { return }
//
//        let user = Auth.auth().currentUser
//        var credential: AuthCredential
//
//        switch userStatus {
//
//        case .logInWithApple:
//            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//                guard let nonce = Helper().currentNonce else {
//                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
//                }
//                guard let appleIDToken = appleIDCredential.identityToken else {
//                    print("Unable to fetch identity token")
//                    return
//                }
//                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
//                    return
//                }
//
//                let credential = OAuthProvider.credential (
//                    withProviderID: "apple.com",
//                    IDToken: appleIdToken,
//                    rawNonce: rawNonce
//                )
//                Auth.auth().currentUser.reauthenticate(with: credential) { (authResult, error) in
//                    guard error != nil else { return }
//                }
//            case _ where user.logStatus == .logInWithGoogle || user.logStatus == .logInWithEmail:
//                user?.reauthenticate(with: credential) { result, error  in
//                    if let error = error {
//
//                    } else {
//
//                    }
//                }
//            }
//        default: break
//        }
//    }
//}
    
    public func logOut(delegate: ASAuthorizationControllerDelegate,presentationContextProvider: ASAuthorizationControllerPresentationContextProviding) {
        
        guard let user = getUser() else { return }
        
        switch user.logStatus {
            
        case .logInWithApple:
            deleteUserApple(delegate: delegate, presentationContextProvider: presentationContextProvider)
        default: break
        }
        
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        
        deleteUserUserDefaults()
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
