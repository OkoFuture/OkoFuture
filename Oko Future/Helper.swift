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
    
    public var currentNonce: String?
    
    static var app: Helper = {
        return Helper()
    }()
    
    public func createUser() {
        Helper().setUser(user: User())
    }
    
    func signIn(completionHandler: @escaping (() -> Void)) {
        
      if GIDSignIn.sharedInstance.hasPreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
            authenticateUser(for: user, with: error, completionHandler: completionHandler)
        }
      } else {
          
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let configuration = GIDConfiguration(clientID: clientID)
          
        GIDSignIn.sharedInstance.configuration = configuration
          
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
          
          GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController, hint: nil, completion: { [unowned self] result, error in
              authenticateUser(for: result?.user, with: error, completionHandler: completionHandler)
            })
      }
    }
    
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?, completionHandler: @escaping (() -> Void)) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        guard let accessToken = user?.accessToken, let idToken = user?.idToken else { return }

        let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)

      Auth.auth().signIn(with: credential) { [unowned self] (_, error) in
        if let error = error {
          print(error.localizedDescription)
        } else {
            
            if let fullname = user?.profile?.name, let email = user?.profile?.email {
                for userDate in UserData.allCases {
                    switch userDate {
                    case .name:
                        Helper().updateUserData(typeUserData: .name, userData: fullname, needUpdateFirebase: false)
                    case .email:
                        Helper().updateUserData(typeUserData: .email, userData: email, needUpdateFirebase: false)
                    default: break
                    }
                }
            }
            
            print ("log in with google completed", user?.profile?.email, user?.profile?.name, user?.profile?.givenName, user?.profile?.familyName, user?.profile?.imageURL(withDimension: 320))
            
            Helper().updateUserLogStatus(logStatus: .logInWithGoogle)
            completionHandler()
        }
      }
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
    
    @available(iOS 13, *)
    func tapLogInApple(delegate: ASAuthorizationControllerDelegate, presentationContextProvider: ASAuthorizationControllerPresentationContextProviding) {
        let nonce = Helper().randomNonceString()
        currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
        request.nonce = Helper().sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = delegate
      authorizationController.presentationContextProvider = presentationContextProvider
      authorizationController.performRequests()
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

        
    
    public func deleteUserApple(delegate: ASAuthorizationControllerDelegate,presentationContextProvider: ASAuthorizationControllerPresentationContextProviding) {
          do {
            let nonce = try randomNonceString()
            currentNonce = nonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)

            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = delegate
            authorizationController.presentationContextProvider = presentationContextProvider
            authorizationController.performRequests()
          } catch {
            // In the unlikely case that nonce generation fails, show error view.
//            displayError(error)
          }
    }
    
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
