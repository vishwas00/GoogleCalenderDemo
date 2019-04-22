//
//  TermsConditionVC.swift
//
//  Created by Anil on 12/04/19.
//  Copyright © 2019 Anil. All rights reserved.
//

import UIKit

protocol TermeConditionDelegate {
	func agreeButtonPressed()
}

class TermsConditionVC: UIViewController {
 var delegate:TermeConditionDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customRightBarButtonTitle(title: "Agree")

        // Do any additional setup after loading the view.
    }
    
    @objc override func btnDoneClickedRightTitle(sender: UIButton){
        delegate?.agreeButtonPressed()
    }

}
