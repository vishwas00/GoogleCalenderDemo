//
//  AdminViewController.swift
//  GoogleCalenderDemo
//
//  Created by Anil Kumar on 05/04/19.
//  Copyright © 2019 Busywizzy. All rights reserved.
//

import UIKit
import Firebase

class AdminViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var userData = [[String: Any]]()
    var mydata = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Indicator.sharedInstance.showIndicator()
        self.tableView.tableFooterView = UIView()
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                self.mydata = user?.uid ?? ""
            }
        }
        self.getUpdatedData()
    }
    
    func getUpdatedData(){
        getusers(completion: { (success) in
            if success{
                DispatchQueue.main.async {
                    self.tableView.delegate = self
                    self.tableView.dataSource = self
                    self.tableView.reloadData()
                    Indicator.sharedInstance.hideIndicator()
                }
            }
        })
    }
    
    func getusers(completion:@escaping (Bool)->()){
        let ref = Database.database().reference(withPath: "Users")
        ref.observe(.value, with: { snapshot in
            print(snapshot.value as Any)
            if let users = snapshot.value as? [String: Any]{
                self.userData.removeAll()
                for i in users.keys{
                    if self.mydata != i{
                        if let data = users[i] as? [String : Any]{
                            if data["email"] as? String != UserDefaults.standard.value(forKey: "email") as? String{
                                self.userData.append(data)
                            }
                        }
                    }
                }
                if self.userData.count == 0 {
                    self.tableView.viewEmptyView(bgImage: UIImage.init(named: "icon_users") ?? UIImage(), errorMsg: "No users found")
                }
                completion(true)
            }else{
                completion(false)
                self.tableView.viewEmptyView(bgImage: UIImage.init(named: "icon_users") ?? UIImage(), errorMsg: "No users found")
                Indicator.sharedInstance.hideIndicator()
            }
        })
    }
    
    func authenticateDeleteUserToken(email: String, password: String,id: String) {
        Indicator.sharedInstance.showIndicator()
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let error = error {
                // An error happened.
                Indicator.sharedInstance.hideIndicator()
                self.showAlert(withTitle: appConstants.KAppName.rawValue, message: error.localizedDescription)
            } else {
                // User re-authenticated.
                user?.user.delete { error in
                    if let error = error {
                        // An error happened.
                        Indicator.sharedInstance.hideIndicator()
                        self.showAlert(withTitle: appConstants.KAppName.rawValue, message: error.localizedDescription)
                    } else {
                        // Account deleted.
                        let ref = Database.database().reference(withPath: "Users")
                        ref.child(id).removeValue { error, _ in
                            
                            let emailUser = UserDefaults.standard.value(forKey: "email") as? String
                            let passwordUser = UserDefaults.standard.value(forKey: "password") as? String
                            
                            Auth.auth().signIn(withEmail: emailUser ?? "", password: passwordUser ?? "") { user, error in
                                if (error == nil){
                                    self.mydata = user?.user.uid ?? ""
                                    self.getUpdatedData()
                                }
                                else {
                                    Indicator.sharedInstance.hideIndicator()
                                    self.showAlert(withTitle: appConstants.KAppName.rawValue, message: error?.localizedDescription ?? "")
                                }
                            }
                        }
                        return
                    }
                }
                
            }
        }
    }
    
    func removeChild(id:String,index: Int){
        self.authenticateDeleteUserToken(email: self.userData[index]["email"] as? String ?? "", password: self.userData[index]["password"] as? String ?? "", id: self.userData[index]["id"] as? String ?? "")
    }
    
    func getusersAccept(index:Int,id: String){
        let ref = Database.database().reference(withPath: "Users")
        let groceryItem = addUserData.init(id: id, name: self.userData[index]["name"] as? String ?? "", completed: false, deviceToken: UUID().uuidString, deviceType: "ios", email: self.userData[index]["email"] as? String ?? "", isActive: true, isAdmin: self.userData[index]["isAdmin"] as? Bool ?? false, password: self.userData[index]["password"] as? String ?? "")
        let groceryItemRef = ref.child(id)
        groceryItemRef.setValue(groceryItem.toAnyObject())
    }
    
    @objc func buttonAcceptTap(sender: UIButton){
        print(sender.tag)
        self.getusersAccept(index: sender.tag, id: userData[sender.tag]["id"] as? String ?? "0")
    }
    @objc func buttonDeclineTap(sender: UIButton){
        print(sender.tag)
        self.showOkAndCancelAlert(withTitle: appConstants.KAppName.rawValue, buttonTitle: "Remove", message: "Are you sure?") {
            self.removeChild(id: self.userData[sender.tag]["id"] as? String ?? "0",index: sender.tag)
        }
    }
}

extension AdminViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as? UserTableViewCell
        cell?.selectionStyle = .none
        cell?.buttonAccept?.tag = indexPath.row
        cell?.buttonAccept?.addTarget(self, action: #selector(self.buttonAcceptTap(sender:)), for: .touchUpInside)
        cell?.buttonRemove?.tag = indexPath.row
        cell?.buttonRemove?.addTarget(self, action: #selector(self.buttonDeclineTap(sender:)), for: .touchUpInside)
        if (userData[indexPath.row]["isActive"] as? Int)?.boolValue == true{
            if let name = userData[indexPath.row]["name"] as? String{
                cell?.labelUserName?.text = name
            }
            cell?.buttonAccept?.isHidden = true
            cell?.buttonRemove?.isHidden = true
        }else {
            if let name = userData[indexPath.row]["name"] as? String{
                cell?.labelUserName?.text = name
            }
            cell?.buttonAccept?.isHidden = false
            cell?.buttonRemove?.isHidden = false
            
        }
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.showOkAndCancelAlert(withTitle: appConstants.KAppName.rawValue, buttonTitle: "Delete", message: "Are you sure you want to remove this user?") {
                print("Deleted")
                self.removeChild(id: self.userData[indexPath.row]["id"] as? String ?? "0", index: indexPath.row)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (userData[indexPath.row]["isActive"] as? Int)?.boolValue == true{
            return true
        }
        return false
    }
}
