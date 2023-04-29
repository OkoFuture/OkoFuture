//
//  Helper.swift
//  Oko Future
//
//  Created by Денис Калинин on 24.04.23.
//

import UIKit

final class Helper {
    
    static var app: Helper = {
        return Helper()
    }()
    
    public func arrayNameAvatarUSDZ() -> [String] {
        ["H_FBX_M_USDx100.usdz", "dressed_girl_2104.usdz"]
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
