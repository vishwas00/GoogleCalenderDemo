//
//  Constants.swift
//  GoogleCalenderDemo
//
//  Created by Anil Kumar on 18/02/19.
//  Copyright © 2019 Busywizzy. All rights reserved.
//

import Foundation
typealias completionHandlerButton = () -> ()

//firebase setup easy way:-
//https://medium.com/xcblog/get-started-with-firebase-for-ios-apps-32a5dc850a28

var driveFileId = ""

struct userDefaultsConstants {
    static var authClientAccessToken = "googleClientToken"
    static var kLastSyncTime = "lastSyncTime"
}

enum googleInfoKeys : String {
    case refreshToken = "1/TE5QtxlnCiuelg_ZiwjDQWE4Mh5DD1VtMK5udTnMtqY"
    case googleApiKey = "AIzaSyCC_NIUvuKqEMomlTNh7KNS-TgT1t7WK98"
    case googleClientSecret = "4Xb90bIWLenMxG5yXg2B8UPL"
    case googleClientId = "290826560562-6iflh5ena0avsg2rd9sjvbv36t3vqes1.apps.googleusercontent.com"
}

enum appConstants : String {
    case KAppName = "App"
}

enum appconfig : Int {
    case kSyncTime = 60
}

struct addTimeintervals  {
    static var defaultTaskCurrentTime = TimeInterval(60)
    static var defaultStartTaskTime = TimeInterval(9 * 60 * 60)
    static var defaultEndTime = TimeInterval(2 * 60 * 60)
    static var defaultEndRemoveTime = TimeInterval(23 * 60 * 60)
}

let workerQueue = DispatchQueue.init(label: "com.worker", attributes: .concurrent)
var calenderTaskName = "Church Task Calender"
var calenderName = "Church Calender"
var calenderAlarm = "com.churuch.alarm"

enum dateCompared {
    case equal
    case ascending
    case descending
}

enum GetApiURL {
    case kAuthGoogle
    case kGetEvents
    case kGetTasks
    case kGetSubTasks
    case kDriveData
    case kDriveDataDownload
    func typeURL()-> String {
        let baseURL = "https://www.googleapis.com/"
        let taskID = CalenderAuth.shared.taskId
    
        switch self {
        case .kAuthGoogle:
            return "https://www.googleapis.com/oauth2/v4/token"
        case .kGetEvents:
            return baseURL + "calendar/v3/calendars/busywizzy1@gmail.com/events?key=\(googleInfoKeys.googleApiKey.rawValue)"
        case .kGetTasks:
            return baseURL + "tasks/v1/users/@me/lists?pp=1&key=\(googleInfoKeys.googleApiKey.rawValue)"
        case .kGetSubTasks:
            return baseURL + "tasks/v1/lists/\(taskID)/tasks?&key=\(googleInfoKeys.googleApiKey.rawValue)"
        case .kDriveData:
            return baseURL + "drive/v2/files"
        case .kDriveDataDownload:
            return baseURL + "drive/v3/files/\(driveFileId)?alt=media"
        }
    }
}

//drive mimeType
enum mimeType : String {
    case image = "image"
    case video = "video"
    case pdf = "pdf"
    case doc = "doc"
    case data = "data"
    case audio = "audio"
    case xml = "xml"
}

enum driveMimeType : String {
    case xls = "application/vnd.ms-excel"
    case xlsx = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    case xml = "text/xml"
    case txt = "text/plain"
    case js = "text/js"
    case ods = "application/vnd.oasis.opendocument.spreadsheet"
    case doc = "application/msword"
    case pdf = "application/pdf"
    case jpg = "image/jpeg"
    case png = "image/png"
    case gif = "image/gif"
    case bmp = "image/bmp"
    case swf = "application/x-shockwave-flash"
    case mp3 = "audio/mpeg"
    case m4a = "audio/x-m4a"
    case zip = "application/zip"
    case rar = "application/rar"
    case tar = "application/tar"
    case arj = "application/arj"
    case cab = "application/cab"
    case html = "text/html"
    case video = "video/quicktime"
    case mp4 = "video/mp4"
    case defaul = "application/octet-stream"
    
    func typeURL()-> mimeType {
        switch self {
        case .jpg:
            return .image
        case .video:
            return .video
        case .mp3:
            return .audio
        case .png:
            return .image
        case .pdf:
            return .pdf
        case .doc:
            return .doc
        case .m4a:
            return .audio
        case .mp4:
            return .video
        case .xml:
            return .xml
        default:
            return .data
        }
    }
}
