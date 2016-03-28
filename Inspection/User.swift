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
    
    var name: String
    var passWord: String
    var authorty: UserPermission
    
    init(userName: String, userPassWord: String, authorty: UserPermission) {
        self.name = userName
        self.passWord = userPassWord
        self.authorty = authorty
    }
}

class UserCenter {
    static var userDB: [User] = [
        User(userName: "admin", userPassWord: "admin", authorty: .admin),
        User(userName: "default", userPassWord: "default", authorty: .defaultUser)

    ]
    
    static var defaultUser: User {
        get {
            return userDB.first!
        }
    }
    
    static var currentUser: User = UserCenter.defaultUser
    
//    func addUser(user: User) {
//        UserCenter.userDB.append(user)
//    }
//    
    
    class func login(loginUserName: String, loginUserPSD: String) -> User? {
        for user in UserCenter.userDB {
            if loginUserName == user.name && loginUserPSD == user.passWord {
                return user
            }
        }
        
        return nil
    }
}