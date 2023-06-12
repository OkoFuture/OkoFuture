//
//  Helper.swift
//  Oko Future
//
//  Created by Денис Калинин on 24.04.23.
//

import UIKit

enum UserData: CaseIterable {
    case name, email, password
}

final class Helper {
    
    static var app: Helper = {
        return Helper()
    }()
    
    public func setUser(user: User) {
        UserDefaults.standard.set(user, forKey: "user")
    }
    
    public func getUser() -> User? {
        return UserDefaults.standard.object(forKey: "user") as? User
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
    
    private func deleteUser() {
        UserDefaults.standard.removeObject(forKey: "user")
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
