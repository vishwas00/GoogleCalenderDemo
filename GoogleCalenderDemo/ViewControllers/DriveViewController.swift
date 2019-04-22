//
//  DriveViewController.swift
//  GoogleCalenderDemo
//
//  Created by Anil Kumar on 12/03/19.
//  Copyright © 2019 Busywizzy. All rights reserved.
//

import UIKit
import ObjectMapper
import Firebase

class DriveViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var tasksObj = [Drive]()
    var url = ""
    var selectedIndexPath = IndexPath()
    var isAudio = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        Indicator.sharedInstance.showIndicator()
        let ref = Database.database().reference(withPath: "Drive")
        ref.observe(.value, with: { snapshot in
            print(snapshot.value as Any)
            self.tasksObj.removeAll()
            ref.removeAllObservers()
            if let users = snapshot.value as? [String: Any]{
                //                self.userData = users
                for i in users.keys{
                    if let userInfoObj = Mapper<Drive>().map(JSONObject: (users[i] as? [String : Any] ?? ["":""])) {
                        self.tasksObj.append(userInfoObj)
                    }
                }
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                Indicator.sharedInstance.hideIndicator()
            }else{
                Indicator.sharedInstance.hideIndicator()
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                self.tableView.viewEmptyView(bgImage: UIImage.init(named: "icons_files") ?? UIImage(), errorMsg: "No data in the drive")
            }
        })
        
    }
    
    //MARK:- Custom methods
    func playVideo(indexPath: IndexPath) {
        driveFileId = tasksObj[indexPath.row].id ?? ""
        if let token = UserDefaults.standard.value(forKey: userDefaultsConstants.authClientAccessToken) as? String{
            musicPlayer.instance.playURL = GetApiURL.kDriveDataDownload.typeURL() + "&access_token=" + token
        }
        musicPlayer.instance.initPlayer(view: self)
        
    }
    
    func docSetupUnknown(indexPath: IndexPath) {
        driveFileId = tasksObj[indexPath.row].embedLink ?? ""
        selectedIndexPath = indexPath
        if let token = UserDefaults.standard.value(forKey: userDefaultsConstants.authClientAccessToken) as? String{
            musicPlayer.instance.playURL = driveFileId + "&access_token=" + token
        }
        url = "\(musicPlayer.instance.playURL)"
        self.performSegue(withIdentifier: "WebViewController", sender: self)
    }
    
    func docSetup(indexPath: IndexPath) {
        driveFileId = tasksObj[indexPath.row].id ?? ""
        selectedIndexPath = indexPath
        if let token = UserDefaults.standard.value(forKey: userDefaultsConstants.authClientAccessToken) as? String{
            musicPlayer.instance.playURL = GetApiURL.kDriveDataDownload.typeURL() + "&access_token=" + token
        }
        url = "\(musicPlayer.instance.playURL)"
        self.performSegue(withIdentifier: "WebViewController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "WebViewController"{
            let destination = segue.destination as! WebViewController
            destination.url = url
            destination.isAudio = isAudio
            destination.title = tasksObj[selectedIndexPath.row].title ?? ""
        }
    }
}

extension DriveViewController : UITableViewDelegate, UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksObj.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.selectionStyle = .none
        
        let labelDate = cell?.viewWithTag(10) as? UILabel
        let dateTask = tasksObj[indexPath.row].createdDate ?? ""
        labelDate?.text = dateTask.DateFromString(format: DateFormat.dateTimeUTC2, convertedFormat: DateFormat.dateMonth)
        let labelTime = cell?.viewWithTag(11) as? UILabel
        labelTime?.text = dateTask.DateFromString(format: DateFormat.dateTimeUTC2, convertedFormat: DateFormat.dayName)
        let labelTitle = cell?.viewWithTag(12) as? UILabel
        labelTitle?.text = tasksObj[indexPath.row].title
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mimeType = tasksObj[indexPath.row].mimeType
        isAudio = false
        switch mimeType?.typeURL() {
        case .image?:
            print("image")
            self.docSetup(indexPath: indexPath)
            break
        case .video?:
            print("video")
            self.playVideo(indexPath: indexPath)
            break
        case .doc?:
            print("doc")
            self.docSetup(indexPath: indexPath)
            break
        case .pdf?:
            print("pdf")
            self.docSetup(indexPath: indexPath)
            break
        case .audio?:
            print("audio")
            isAudio = true
            self.docSetup(indexPath: indexPath)
            break
        case .xml?:
            print("xml")
            self.docSetup(indexPath: indexPath)
            break
        default:
            print("default")
            self.docSetupUnknown(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    
}
//MARK:- Api call
extension DriveViewController {
    func apiCallenderDriveSync(compeltion: @escaping ()->()) {
        
        HttpClient.getRequest(urlString: GetApiURL.kDriveData.typeURL(),header: true,loaderEnable: true, successBlock: { (response) in
            
            if let webServiceData = response as? Dictionary<String,Any>{
                if let data = webServiceData["items"] as? [Dictionary<String,Any>]{
                    self.tasksObj.removeAll()
                    for dataupdate in data {
                        if let userInfoObj = Mapper<Drive>().map(JSONObject: dataupdate) {
                            self.tasksObj.append(userInfoObj)
                        }
                    }
                    compeltion()
                } else if let error = webServiceData["error"] as? Dictionary<String,Any>{
                    if error["code"] as? Int == ErrorCode.UnAuthorized.rawValue{ //get unauthorized token
                        self.showAlert(withTitle: appConstants.KAppName.rawValue, message: ErrorMessage.UnAuthorized.rawValue)
                    }
                }
            }
        }) { (error) in
            self.showAlert(withTitle: appConstants.KAppName.rawValue, message: error)
        }
    }
}
