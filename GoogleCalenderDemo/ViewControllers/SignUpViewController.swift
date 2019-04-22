//
//  SignUpViewController.swift
//  GoogleCalenderDemo
//
//  Created by Anil Kumar on 01/04/19.
//  Copyright © 2019 Busywizzy. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    //MARK:- IBOutlets
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var buttonOutletCheckBox: UIButton!
    @IBOutlet weak var textFieldFirstName: UITextField!
    @IBOutlet weak var textFieldLastName: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    var user: User!
    let ref = Database.database().reference(withPath: "Users")
    
    //MARK:-View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func validateUser()-> Bool{
        guard textFieldEmail.text?.count != 0 else {
            self.showAlert(withTitle: appConstants.KAppName.rawValue, message: "Enter email address", completion: nil)
            return false
        }
        guard textFieldFirstName.text?.count != 0 else {
            self.showAlert(withTitle: appConstants.KAppName.rawValue, message: "Enter first name", completion: nil)
            return false
        }
        guard textFieldLastName.text?.count != 0 else {
            self.showAlert(withTitle: appConstants.KAppName.rawValue, message: "Enter last name", completion: nil)
            return false
        }
        guard textFieldPassword.text?.count != 0  else {
            self.showAlert(withTitle: appConstants.KAppName.rawValue, message: "Enter password ", completion: nil)
            return false
        }
        guard (textFieldEmail.text?.isValidEmail())! else {
            self.showAlert(withTitle: appConstants.KAppName.rawValue, message: "Enter valid email address", completion: nil)
            return false
        }
        guard buttonOutletCheckBox.currentImage == UIImage.init(named: "check-square") else {
            self.showAlert(withTitle: appConstants.KAppName.rawValue, message: "Please accept the terms and conditions.", completion: nil)
            return false
        }
        self.view.endEditing(true)
        return true
    }
    
    func registerUser(){
        if validateUser(){
            Indicator.sharedInstance.showIndicator()
        Auth.auth().createUser(withEmail: textFieldEmail.text!, password: textFieldPassword.text!) { user, error in
            if error == nil {
                self.storeUser(id: user?.user.uid ?? "")
            }else{
                self.showAlert(withTitle: appConstants.KAppName.rawValue, message: error?.localizedDescription ?? "")
            }
        }
        }else {
            
        }
    }
    
    func sendEmail(completion:@escaping (Bool)->()){
        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            if error == nil {
               completion(true)
            }else{
                completion(false)
            }
        })
    }
    
    func storeUser(id: String){
        let groceryItem = addUserData.init(id: id, name: self.textFieldFirstName.text! + " " + self.textFieldLastName.text! , completed: false, deviceToken: UUID().uuidString, deviceType: "ios", email: self.textFieldEmail.text!, isActive: false, isAdmin: false, password: self.textFieldPassword.text!)
        let groceryItemRef = self.ref.child(id)
        groceryItemRef.setValue(groceryItem.toAnyObject())
        self.sendEmail { (success) in
            if success {
                self.showAlert(withTitle: appConstants.KAppName.rawValue, message: "You are successfully register. Verification link has been sent to your registered email address: \(self.textFieldEmail.text!). Please verify it.") {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            Indicator.sharedInstance.hideIndicator()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TermsConditionVC"{
            let destination = segue.destination as! TermsConditionVC
            destination.delegate = self

        }
    }
    
    //MARK:- Privacy Policy
    @IBAction func buttonActionSubmit(_ sender: Any) {
        self.registerUser()
    }
    
    @IBAction func buttonActionAlreadyRegister(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonActionCheck(_ sender: UIButton) {
        if (sender.currentImage == UIImage.init(named: "check-square")){
            sender.setImage(UIImage.init(named: "square"), for: .normal)
        }else{
            sender.setImage(UIImage.init(named: "check-square"), for: .normal)
        }
    }
}
extension SignUpViewController: TermeConditionDelegate{
    func agreeButtonPressed() {
        buttonOutletCheckBox.setImage(UIImage.init(named: "check-square"), for: .normal)
    }
    
}
