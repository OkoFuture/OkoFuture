//
//  User.swift
//  Oko Future
//
//  Created by Денис Калинин on 09.06.23.
//

import Foundation

enum UserData: CaseIterable, Codable {
    case name, email, password
}

enum UserLogStatus: Codable {
    case logInWithApple, logInWithGoogle, logInWithEmail, logOut
}

final class User: Codable {
    
    var name: String? = nil
    var email: String? = nil
    var password: String? = nil
    
    var imageProfile: URL? = nil
    
    var logStatus: UserLogStatus = .logOut
}
