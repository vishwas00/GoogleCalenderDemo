//
//  CalenderDataModel.swift
//  GoogleCalenderDemo
//
//  Created by Anil Kumar on 18/02/19.
//  Copyright © 2019 Busywizzy. All rights reserved.
//

import Foundation
import ObjectMapper

class calenderobj: Mappable {
    var updated : date?
    var summary: String?
    var status : String?
    var description : String?
    var endDate : endDate?
    var id : String?
    var date: String?
    var dateEnd: String?
    required init?(map: Map) {
        mapping(map: map)
    }
    // Mappable 
    func mapping(map: Map) {
        updated <- map["start"]
        endDate <- map["endDate"]
        summary <- map["summary"]
        status <- map["status"]
        description <- map["description"]
        id <- map["id"]
        date <- map["date"]
        dateEnd <- map["dateEnd"]
    }
}

class date: Mappable {
    var start : String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    // Mappable
    func mapping(map: Map) {
        start <- map["dateTime"]
    }
}
class endDate: Mappable {
    var end : String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    // Mappable
    func mapping(map: Map) {
        end <- map["dateTime"]
    }
}
