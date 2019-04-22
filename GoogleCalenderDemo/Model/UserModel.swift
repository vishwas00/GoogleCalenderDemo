//
//  UserModel.swift
//  GoogleCalenderDemo
//
//  Created by Anil Kumar on 04/04/19.
//  Copyright © 2019 Busywizzy. All rights reserved.
//

import Foundation
import Firebase

struct addUserData {
    let id : String
    let ref: DatabaseReference?
    let key: String
    let name: String
    let deviceToken: String
    let deviceType: String
    let email: String
    let isActive: Bool
    var isAdmin: Bool
    var password: String
    
    init(id: String, name: String, completed: Bool, key: String = "",deviceToken: String, deviceType: String, email: String,isActive: Bool,isAdmin: Bool,password: String) {
        self.ref = nil
        self.key = key
        self.name = name
        self.deviceToken = deviceToken
        self.deviceType = deviceType
        self.email = email
        self.isActive = isActive
        self.isAdmin = isAdmin
        self.password = password
        self.id = id
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let name = value["name"] as? String,
            let deviceToken = value["deviceToken"] as? String,
            let deviceType = value["deviceType"] as? String,
            let email = value["email"] as? String,
            let isActive = value["isActive"] as? Bool,
            let password = value["password"] as? String,
            let isAdmin = value["isAdmin"] as? Bool,
            let id = value["id"] as? String
            else {
                return nil
        }
        self.id = id
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.name = name
        self.deviceToken = deviceToken
        self.deviceType = deviceType
        self.email = email
        self.isActive = isActive
        self.isAdmin = isAdmin
        self.password = password
    }
    
    func toAnyObject() -> Any {
        return [
            "id": id,
            "name": name,
            "isAdmin": isAdmin,
            "deviceToken": deviceToken,
            "deviceType": deviceType,
            "email": email,
            "isActive": isActive,
            "password": password
        ]
    }
}
