//
//  SignInViewController.swift
//  GoogleCalenderDemo
//
//  Created by Anil Kumar on 01/04/19.
//  Copyright © 2019 Busywizzy. All rights reserved.
//

import UIKit
import Firebase
class SignInViewController: UIViewController {
    
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    var userdata : [String: Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func validateUser()-> Bool{
        guard textFieldEmail.text?.count != 0 else {
            self.showAlert(withTitle: appConstants.KAppName.rawValue, message: "Enter email address", completion: nil)
            return false
        }
        guard textFieldPassword.text?.count != 0 else {
            self.showAlert(withTitle: appConstants.KAppName.rawValue, message: "Enter password", completion: nil)
            return false
        }
        
        return true
    }
    
    func signin(sender: UIButton){
        if validateUser(){
            self.view.endEditing(true)
            Indicator.sharedInstance.showIndicator()
            guard
                let email = textFieldEmail.text,
                let password = textFieldPassword.text,
                email.count > 0,
                password.count > 0
                else {
                    return
            }
            sender.isUserInteractionEnabled = true
            Auth.auth().signIn(withEmail: email, password: password) { user, error in
                if let error = error, user == nil {
                    Indicator.sharedInstance.hideIndicator()
                    let alert = UIAlertController(title: "Sign In Failed", message: error.localizedDescription,preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    
                    self.present(alert, animated: true, completion: nil)
                }else {
                        if user != nil {
                            UserDefaults.standard.set(user?.user.email, forKey: "email")
                            let ref = Database.database().reference(withPath: "Users")
                            ref.child(user?.user.uid ?? "").observe(.value, with: { snapshot in
                                print(snapshot.value as Any)
                                ref.child(user?.user.uid ?? "").removeAllObservers()
                                Indicator.sharedInstance.hideIndicator()
                                guard Auth.auth().currentUser?.isEmailVerified == true else {
                                    self.showAlert(withTitle: appConstants.KAppName.rawValue, message: "Please verify your email address.", completion: nil)
                                    return
                                }
                                if let userData = snapshot.value as? [String: Any]{
                                    if (userData["isActive"] as? Int ?? 0 ).boolValue == true{
                                        UserDefaults.standard.set(userData["password"], forKey: "password")
                                        self.userdata = userData
                                        self.performSegue(withIdentifier: "CalenderViewController", sender: self)
                                        self.textFieldEmail.text = nil
                                        self.textFieldPassword.text = nil
                                        UserDefaults.standard.set(user?.user.uid, forKey: "id")
                                    } else {
                                        self.showAlert(withTitle: appConstants.KAppName.rawValue, message: "Your account is not activate.Please contact system administrator.", completion: nil)
                                    }
                                }else{
                                    self.showAlert(withTitle: appConstants.KAppName.rawValue, message: "You are not registered with us.", completion: nil)
                                }
                            })
                    }
                }
            }
        }
    }
    
    @IBAction func buttonActionLogin(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        signin(sender: sender)
    }
    
    @IBAction func buttonActionResetPassword(_ sender: Any) {
        self.performSegue(withIdentifier: "ResetPasswordViewController", sender: self)
    }
    
    @IBAction func buttonActionRegisterAccount(_ sender: Any) {
    }
}
