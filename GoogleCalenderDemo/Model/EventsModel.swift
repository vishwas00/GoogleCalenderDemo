//
//  EventsModel.swift
//  GoogleCalenderDemo
//
//  Created by Anil Kumar on 09/04/19.
//  Copyright © 2019 Busywizzy. All rights reserved.
//

import Foundation
import Firebase

struct EventsModel {
    
    let ref: DatabaseReference?
    let key: String
    let updated: String
    let summary: String
    let status: String
    let description: String
    let dateEnd: String
    
    init(updated: String, summary: String, key: String = "",status: String, description: String, dateEnd: String) {
        self.ref = nil
        self.key = key
        self.updated = updated
        self.summary = summary
        self.status = status
        self.description = description
        self.dateEnd = dateEnd
    }
    
    init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: AnyObject],
            let summary = value["summary"] as? String,
            let updated = value["updated"] as? String,
            let status = value["status"] as? String,
            let description = value["description"] as? String,
            let dateEnd = value["dateEnd"] as? String
        else {
            return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.summary = summary
        self.updated = updated
        self.status = status
        self.description = description
    self.dateEnd = dateEnd
    }
    
    func toAnyObject() -> Any {
        return [
            "summary": summary,
            "updated": updated,
            "status": status,
            "description": description,
            "date": updated,
            "dateEnd": dateEnd
        ]
    }
}
