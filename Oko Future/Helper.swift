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
    
    public func showAlert(title: String?, message: String?, view: UIViewController, actions: [UIAlertAction], animated: Bool = true, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for action in actions {
            alert.addAction(action)
        }
        
        view.present(alert, animated: animated, completion: completion)
    }
    
    public func arrayNameAvatarUSDZ() -> [String] {
//        ["avtr_anim_0805.usdz", "avtr_anim_0805.usdz"]
        ["avtr_anim_0606", "avtr_anim_0606"]
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
