//
//  UserService.swift
//  Oko Future
//
//  Created by Денис Калинин on 26.06.23.
//

import Foundation

final class UserService {
    
    public func createUser() {
        setUser(user: User())
    }
    
    public func updateUserLogStatus(logStatus: UserLogStatus) {
        guard let user = getUser() else { return }
        
        user.logStatus = logStatus
        
        setUser(user: user)
    }
    
    public func deleteUserUserDefaults() {
        
        UserDefaults.standard.removeObject(forKey: "user")
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
}
