//
//  TaskModel.swift
//  GoogleCalenderDemo
//
//  Created by Anil Kumar on 09/04/19.
//  Copyright © 2019 Busywizzy. All rights reserved.
//

import Foundation
import Firebase

struct TaskModel {
    
    let ref: DatabaseReference?
    let key: String
    let id: String
    let title: String
    let selfLink: String
    let subTask: String
    
    init(id: String, title: String, key: String = "",selfLink: String, subTask: String) {
        self.ref = nil
        self.key = key
        self.id = id
        self.title = title
        self.selfLink = selfLink
        self.subTask = subTask
    }
    
    init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: AnyObject],
            let id = value["id"] as? String,
            let title = value["title"] as? String,
            let selfLink = value["selfLink"] as? String,
            let subtask = value["subTask"] as? String

            else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.id = id
        self.title = title
        self.selfLink = selfLink
        self.subTask = subtask
    }
    
    func toAnyObject() -> Any {
        return [
            "id": id,
            "title": title,
            "selfLink": selfLink,
            "subtask": subTask
        ]
    }
}
