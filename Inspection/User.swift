//
//  User.swift
//  Inspection
//
//  Created by apple on 16/3/8.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import Foundation

class User {
    
    enum UserPermission {
        case defaultUser
        case admin
    }
    
    var userName: String
    var passWord: String
    var authorty: UserPermission
    
    init(userName: String, passWord: String, authorty: UserPermission) {
        self.userName = userName
        self.passWord = passWord
        self.authorty = authorty
    }
}

class UserCenter {
    static var userDB: [User] = [
        User(userName: "default", passWord: "default", authorty: .defaultUser),
        User(userName: "admin", passWord: "admin", authorty: .admin)
    ]
    
    static var defaultUser: User {
        get {
            return userDB.first!
        }
    }
    
    static var currentUser: User = UserCenter.defaultUser
    
    func addUser(user: User) {
        UserCenter.userDB.append(user)
    }
    
    
    func login(userName: String, passWord: String) -> User {
        for user in UserCenter.userDB {
            if userName == user.userName && passWord == user.passWord {
                return user
            }
        }
        
        return UserCenter.defaultUser
    }
}