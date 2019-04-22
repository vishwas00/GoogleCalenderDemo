import ObjectMapper
class Drive: Mappable {
    var id : String?
    var title : String?
    var thumbnailLink : String?
    var webContentLink : String?
    var originalFilename : String?
    var fileSize : String?
    var createdDate :  String?
    var iconLink : String?
    var mimeType : driveMimeType?
    var embedLink : String?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    // Mappable
    func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        thumbnailLink <- map["thumbnailLink"]
        webContentLink <- map["webContentLink"]
        originalFilename <- map["originalFilename"]
        fileSize <- map["fileSize"]
        createdDate <- map["createdDate"]
        mimeType <- map["mimeType"]
        iconLink <- map["iconLink"]
        embedLink <- map["embedLink"]
    }
}
