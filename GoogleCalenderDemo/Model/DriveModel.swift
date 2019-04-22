//
//  DriveModel.swift
//  GoogleCalenderDemo
//
//  Created by Anil Kumar on 09/04/19.
//  Copyright © 2019 Busywizzy. All rights reserved.
//

import Foundation
import Firebase

struct DriveModel {
    
    let ref: DatabaseReference?
    let key: String
    let id : String?
    let title : String?
    let thumbnailLink : String?
    let webContentLink : String?
    let originalFilename : String?
    let fileSize : String?
    let createdDate :  String?
    let iconLink : String?
    let mimeType : String?
    let embedLink : String?
    
    
    init(title: String, thumbnailLink: String, key: String = "",webContentLink: String, originalFilename: String,fileSize: String, createdDate: String,iconLink: String, mimeType: String, embedLink : String,id: String) {
        self.ref = nil
        self.key = key
        self.title = title
        self.thumbnailLink = thumbnailLink
        self.id = id
        self.webContentLink = webContentLink
        self.fileSize = fileSize
        self.createdDate = createdDate
        self.iconLink = iconLink
        self.mimeType = mimeType
        self.embedLink = embedLink
        self.originalFilename = originalFilename
    }
    
    init?(snapshot: DataSnapshot) {
        guard let value = snapshot.value as? [String: AnyObject],
            let title = value["title"] as? String,
            let thumbnailLink = value["thumbnailLink"] as? String,
            let id = value["id"] as? String,
            let webContentLink = value["webContentLink"] as? String,
            let fileSize = value["fileSize"] as? String,
            let createdDate = value["createdDate"] as? String,
            let iconLink = value["iconLink"] as? String,
            let mimeType = value["mimeType"] as? String,
            let embedLink = value["embedLink"] as? String,
            let originalFilename = value["originalFilename"] as? String
            else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.title = title
        self.thumbnailLink = thumbnailLink
        self.id = id
        self.webContentLink = webContentLink
        self.fileSize = fileSize
        self.createdDate = createdDate
        self.iconLink = iconLink
        self.mimeType = mimeType
        self.embedLink = embedLink
        self.originalFilename = originalFilename
    }
    
    func toAnyObject() -> Any {
        return [
            "key": key,
            "title": title,
            "thumbnailLink": thumbnailLink,
            "id": id,
            "webContentLink": webContentLink,
            "fileSize": fileSize,
            "createdDate": createdDate,
            "iconLink": iconLink,
            "mimeType": mimeType,
            "embedLink": embedLink,
            "originalFilename" :originalFilename
        ]
    }
}
