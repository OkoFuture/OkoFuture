//
//  User.swift
//  Oko Future
//
//  Created by Денис Калинин on 09.06.23.
//

import Foundation

final class User {
    
    var name: String? = nil
    var email: String? = nil
    var password: String? = nil
    
    var imageAvatar: URL? = nil
    
    var logInWithApple: Bool = false
    var logInWithGoogle: Bool = false
    var logIn: Bool = false
}
