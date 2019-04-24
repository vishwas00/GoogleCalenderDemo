//
//  CalenderViewController.swift
//  GoogleCalenderDemo
//
//  Created by Anil Kumar on 18/02/19.
//  Copyright © 2019 Busywizzy. All rights reserved.
//

import UIKit
import ObjectMapper
import GoogleSignIn
import Firebase

class CalenderViewController: UIViewController {
    @IBOutlet weak var buttonOutletTasks: UIButton!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var buttonOutletDrive: UIButton!
    @IBOutlet weak var buttonOutletSync: UIButton!
    @IBOutlet weak var buttonAdminRole: UIButton!
    @IBOutlet weak var laelAdminRole: UILabel!
    
    //MARK:- variables
    var calenderEvents = [calenderobj]()
    var calendarTasks = [Task]()
    var calendarSubTasks = [SubTask]()
    var calenderDrive = [Drive]()
    let refEvents = Database.database().reference(withPath: "Events")
    let refTask = Database.database().reference(withPath: "Tasks")
    let refDrive = Database.database().reference(withPath: "Drive")
    
    //MARK:- View Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        Indicator.sharedInstance.showIndicator()
        DispatchQueue.global(qos: .userInteractive).sync { [weak self] in
            guard let self = self else {
                return
            }
            self.isAdmin { (success, data) in
                Indicator.sharedInstance.hideIndicator()
                if success{
                    self.buttonAdminRole.isHidden = false
                    self.laelAdminRole.isHidden = false
                    self.buttonOutletSync.isHidden = false
                } else {
                    self.buttonAdminRole.isHidden = true
                    self.laelAdminRole.isHidden = true
                    self.buttonOutletSync.isHidden = true
                }
                self.needFetchGoogleToken(isSync: false)
            }
        }
        self.customRightBarButton(image: UIImage.init(named: "error") ?? UIImage())
    }

    override func viewWillAppear(_ animated: Bool) {
        self.customLeftBarButton(title: "Logout")
    }
    
    func isAdmin(completion:@escaping (Bool,[String: Any])->()){
        let id = UserDefaults.standard.value(forKey: "id") as? String
        let ref = Database.database().reference(withPath: "Users")
        ref.child(id ?? "").observe(.value, with: { snapshot in
            print(snapshot.value as Any)
            if let userData = snapshot.value as? [String: Any]{
                if (userData["isActive"] as? Int ?? 0 ).boolValue == true{
                    if (userData["isAdmin"] as? Int ?? 0 ).boolValue == true {
                        completion(true, userData)
                    }else {
                        completion(false, ["":""])
                    }
                }
            }else{
                self.showAlert(withTitle: appConstants.KAppName.rawValue, message: "You are not registered with us.", completion: {
                    self.logout()
                })
                }
        })
    }
    
    func removeAllChild(completion: @escaping ()->()){
        refEvents.removeValue { error, _ in
            self.refDrive.removeValue { error, _ in
                self.refTask.removeValue { error, _ in
                    completion()
                }
            }
        }
    }
    
    func getTaskApi(completion:@escaping ()->()) {
        self.apiCallenderTaskSync {
            for (index,_) in self.calendarTasks.enumerated(){
                CalenderAuth.shared.taskId = self.calendarTasks[index].id ?? ""
                self.apiCallenderSubTaskSync(index: index) {
                    completion()
                }
            }
        }
    }
    
    func storeEvents(completion:()->()){
        for i in self.calenderEvents{
            let eventsItems = EventsModel.init(updated: i.updated?.start ?? "", summary: i.summary ?? "", status: i.status ?? "", description: i.description ?? "",dateEnd: i.endDate?.end ?? "")
            let groceryItemRef = self.refEvents.child(i.id ?? "id")
            groceryItemRef.setValue(eventsItems.toAnyObject())
        }
        completion()
    }
    
    func storeDrive(completion:()->()){
        for i in self.calenderDrive{
            let eventsItems = DriveModel.init(title: i.title ?? "", thumbnailLink: i.thumbnailLink ?? "", webContentLink: i.webContentLink ?? "", originalFilename: i.originalFilename ?? "", fileSize: i.fileSize ?? "", createdDate: i.createdDate ?? "", iconLink: i.iconLink ?? "", mimeType: i.mimeType.map { $0.rawValue } ?? "", embedLink: i.embedLink ?? "", id: i.id ?? "")
            let groceryItemRef = self.refDrive.child(i.id ?? "id")
            groceryItemRef.setValue(eventsItems.toAnyObject())
        }
        completion()
    }
    
    func storeTasks(completion:()->()){
        for i in self.calendarTasks{
            
            let eventsItems = TaskModel.init(id: i.id ?? "", title: i.title ?? "", selfLink: i.selfLink ?? "", subTask: i.subTask.toJSONString() ?? "")
            let groceryItemRef = self.refTask.child(i.id ?? "id")
            groceryItemRef.setValue(eventsItems.toAnyObject())
        }
        completion()
    }
    
    func syncData(){
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else {
                return
            }
            Indicator.sharedInstance.showIndicator()
            self.removeAllChild(){
                self.apiCallenderSync(compeltion: { //events
                    print(self.calenderEvents)
                    self.storeEvents {
                        self.getTaskApi(){      //tasks
                            self.storeTasks {
                                self.apiCallenderDriveSync(compeltion: { //drive
                                    self.storeDrive {
                                        self.showAlert(withTitle: appConstants.KAppName.rawValue, message: "Data sync successfully with the server.")
                                    }
                                    print(self.calenderEvents)
                                })
                            }
                        }
                    }
                    //                self.storeDataToCalender()
                })
            }
        }
    }
    
    func needFetchGoogleToken(isSync: Bool) {
        self.getLastSyncTime { (success) in
            if success{ // more than 1 hrs
                self.getAuthGoogleApi(isSync: isSync)
            } else { //less than 1hrs
                self.isAdmin { (success, data) in
                    if success  && isSync{
                        self.syncData()
                    }else{
                        Indicator.sharedInstance.hideIndicator()
                    }
                }
            }
        }
    }
    
    func getAuthGoogleApi(isSync: Bool) {
        self.apiClientAuthToken { success in
            if success {//get auth token
                self.isAdmin { (success, data) in
                    if success && isSync{
                        self.syncData()
                    }else{
                        Indicator.sharedInstance.hideIndicator()
                    }
                }
            }
        }
    }
    
    func logout(){
        do {
        try Auth.auth().signOut()
        UserDefaults.standard.removeObject(forKey: "id")
        UserDefaults.standard.removeObject(forKey:  userDefaultsConstants.kLastSyncTime)
        let SignInViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let nav = UINavigationController(rootViewController: SignInViewController)
        appDelegate.window?.rootViewController = nav
        
        } catch (let error) {
            print("Auth sign out failed: \(error)")
        }
    }
    
    @IBAction func buttonActionSync(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func buttonActionAdminRole(_ sender: Any) {
        self.performSegue(withIdentifier: "AdminViewController", sender: self)
    }
    
    @IBAction func buttonActionEventsCalendar(_ sender: UIButton) {
        self.performSegue(withIdentifier: "TaskViewController", sender: self)
    }
    
    @IBAction func buttonActionCalender(_ sender: Any) {
        self.performSegue(withIdentifier: "ViewController", sender: self)
    }
    @IBAction func buttonActionDrive(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "DriveViewController", sender: self)
    }
    
    @objc override func btnDoneClickedLeft(sender:UIButton)
    { //Dne Button
        self.showOkAndCancelAlert(withTitle: appConstants.KAppName.rawValue, buttonTitle: "Logout", message: "Are you sure you want to logout?") {
            
            let user = Auth.auth().currentUser!
            let onlineRef = Database.database().reference(withPath: "online/\(user.uid)")
            onlineRef.removeValue { (error, _) in
                if let error = error {
                    print("Removing online failed: \(error)")
                    return
                }
                self.logout()
            }
            
        }
    }
    
    @objc override func btnDoneClicked(sender:UIButton)
    { //Dne Button
        exit(0)
    }

}

extension CalenderViewController : GIDSignInDelegate,GIDSignInUIDelegate {
    
    //MARK:- Google Delegates
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if (error == nil) {
            let userId = user.userID
            print(userId ?? "Not found")
//            let token = user.authentication.accessToken
//            UserDefaults.standard.setValue(token, forKey: userDefaultsConstants.authMyToken)
            self.needFetchGoogleToken(isSync: true)
        } else {
            print("\(error.localizedDescription)")
            buttonOutletTasks.isUserInteractionEnabled = true
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    // pressed the Sign In button
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        print(signIn.clientID)
    }
    
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
//MARK:- Api Call
extension CalenderViewController{
    func apiClientAuthToken(compeltion: @escaping (Bool)->()) {
        let methodParameters = ["grant_type" : "refresh_token","client_id": googleInfoKeys.googleClientId.rawValue,"client_secret":googleInfoKeys.googleClientSecret.rawValue,"refresh_token": googleInfoKeys.refreshToken.rawValue] as [String : Any]
        HttpClient.postRequest(urlString: GetApiURL.kAuthGoogle.typeURL(), requestData: methodParameters,headerRequired: false,successBlock: { (success) in
            print(success)
            UserDefaults.standard.setValue(success["access_token"] ?? "", forKey: userDefaultsConstants.authClientAccessToken)
            UserDefaults.standard.setValue(Date(), forKey: userDefaultsConstants.kLastSyncTime)
            compeltion(true)
        }) { (error) in
            print(error)
            Indicator.sharedInstance.hideIndicator()
            self.showAlert(withTitle: appConstants.KAppName.rawValue, message: error.debugDescription )
            compeltion(false)
        }
    }
    
    func apiCallenderSync(compeltion: @escaping ()->()) {
        
        HttpClient.getRequest(urlString: GetApiURL.kGetEvents.typeURL(),loaderEnable: true, successBlock: { (response) in
            
            if let webServiceData = response as? Dictionary<String,Any>{
                if let data = webServiceData["items"] as? [Dictionary<String,Any>]{
                    self.calenderEvents.removeAll()
                    for dataupdate in data {
                        if let userInfoObj = Mapper<calenderobj>().map(JSONObject: dataupdate) {
                            self.calenderEvents.append(userInfoObj)
                        }
                    }
                    compeltion()
                }
            }
        }) { (error) in
            Indicator.sharedInstance.hideIndicator()
            self.showAlert(withTitle: appConstants.KAppName.rawValue, message: error)
        }
    }
    
    func apiCallenderTaskSync(compeltion: @escaping ()->()) {
        HttpClient.getRequest(urlString: GetApiURL.kGetTasks.typeURL(), header: true,loaderEnable: true, successBlock: { (response) in
            
            if let webServiceData = response as? Dictionary<String,Any>{
                if let data = webServiceData["items"] as? [Dictionary<String,Any>]{
                    self.calendarTasks.removeAll()
                    for dataupdate in data {
                        if let userInfoObj = Mapper<Task>().map(JSONObject: dataupdate) {
                            self.calendarTasks.append(userInfoObj)
                        }
                    }
                    compeltion()
                }else if let error = webServiceData["error"] as? Dictionary<String,Any>{
                    if error["code"] as? Int == ErrorCode.UnAuthorized.rawValue{ //get unauthorized token
                        self.getTaskApi(completion:{})
                    }
                }
                else {
                    self.view.viewEmptyView(bgImage: UIImage.init(named: "calendar") ?? UIImage(), errorMsg: "No Task in the list.")
                }
            }
        }) { (error) in
            Indicator.sharedInstance.hideIndicator()
            self.showAlert(withTitle: appConstants.KAppName.rawValue, message: error)
        }
    }
    
    func apiCallenderSubTaskSync(index: Int, compeltion: @escaping ()->()) {
        HttpClient.getRequest(urlString: GetApiURL.kGetSubTasks.typeURL(), header: true,loaderEnable: true, successBlock: { (response) in
            
            if let webServiceData = response as? Dictionary<String,Any>{
                if let data = webServiceData["items"] as? [Dictionary<String,Any>]{
                    self.calendarSubTasks.removeAll()
                    for dataupdate in data {
                        if let userInfoObj = Mapper<SubTask>().map(JSONObject: dataupdate) {
                            self.calendarSubTasks.append(userInfoObj)
                        }
                    }
                    if self.calendarSubTasks.count != 0{
                        self.calendarTasks[index].subTask = self.calendarSubTasks
                        self.calendarSubTasks.removeAll()
                    }
                    compeltion()
                }else {
                    //No subtask
                    compeltion()
                }
            }
        }) { (error) in
            Indicator.sharedInstance.hideIndicator()
            self.showAlert(withTitle: appConstants.KAppName.rawValue, message: error)
        }
    }
    
    func apiCallenderDriveSync(compeltion: @escaping ()->()) {
        
        HttpClient.getRequest(urlString: GetApiURL.kDriveData.typeURL(),header: true,loaderEnable: true, successBlock: { (response) in
            
            if let webServiceData = response as? Dictionary<String,Any>{
                if let data = webServiceData["items"] as? [Dictionary<String,Any>]{
                    self.calenderDrive.removeAll()
                    for dataupdate in data {
                        if let userInfoObj = Mapper<Drive>().map(JSONObject: dataupdate) {
                            if driveMimeType(rawValue: dataupdate["mimeType"] as? String ?? "") != nil {
                                self.calenderDrive.append(userInfoObj)
                            }
                        }
                    }
                    compeltion()
                } else if let error = webServiceData["error"] as? Dictionary<String,Any>{
                    if error["code"] as? Int == ErrorCode.UnAuthorized.rawValue{ //get unauthorized token
                        self.showAlert(withTitle: "App", message: ErrorMessage.UnAuthorized.rawValue)
                    }
                }
                compeltion()
            }
        }) { (error) in
            Indicator.sharedInstance.hideIndicator()
            self.showAlert(withTitle: appConstants.KAppName.rawValue, message: error)
        }
    }
}
