//
//  ResetPasswordViewController.swift
//  GoogleCalenderDemo
//
//  Created by Anil Kumar on 11/04/19.
//  Copyright © 2019 Busywizzy. All rights reserved.
//

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController {
    @IBOutlet weak var textFieldEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func buttonActionCancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonActionSend(_ sender: Any) {
        if self.textFieldEmail.text?.count == 0{
            self.showAlert(withTitle: appConstants.KAppName.rawValue, message: "Enter email id first.")
        }else {
            self.view.endEditing(true)
            Auth.auth().sendPasswordReset(withEmail: textFieldEmail.text ?? "") { error in
                if error == nil {
                    self.showAlert(withTitle: appConstants.KAppName.rawValue, message: "Email sent successfully.", completion: {
                        self.textFieldEmail.text = ""
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }
        }
    }
}
