//
//  Helper.swift
//  Oko Future
//
//  Created by Денис Калинин on 24.04.23.
//

import UIKit
import Firebase


final class Helper {
    
    static var app: Helper = {
        return Helper()
    }()
    
    public func createUser() {
        Helper().setUser(user: User())
    }
    
    public func addUserFirebase(email: String, password: String) {
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            
        }
    }
    
    public func updateUserFirebase() {
        guard let user = getUser() else { return }
        
//        let userFire: FirebaseAuth.User =
        
//        Auth.auth().updateCurrentUser(user)
    }
    
    public func setUser(user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "user")
        }
        
//        Auth.auth().updateCurrentUser(<#T##user: User##User#>)
    }
    
    public func getUser() -> User? {
        guard let data = UserDefaults.standard.object(forKey: "user") as? Data else { return nil }
        guard let user = try? JSONDecoder().decode(User.self, from: data) else { return nil }
        return user
    }
    
    public func updateUserData(typeUserData: UserData, userData: String) {
        
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
//        Auth.auth()
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
