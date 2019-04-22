//
//  ViewExtension.swift
//  GoogleCalenderDemo
//
//  Created by Anil Kumar on 18/02/19.
//  Copyright © 2019 Busywizzy. All rights reserved.
//

import Foundation
import  UIKit
extension UIView {
    func viewEmptyView(bgImage: UIImage, errorMsg: String) {
        let bGImageView = UIImageView.init(image: bgImage)
        bGImageView.frame = CGRect(x: 0, y: 0, width: 100 , height: 100)
        bGImageView.center = self.center
        bGImageView.center.y -= 150
        self.addSubview(bGImageView)
        
        let textError = UILabel()
        textError.frame = CGRect(x: 0, y: 0, width: self.frame.width , height: 100)
        textError.text = errorMsg
        textError.textAlignment = .center
        textError.textColor = .black
        textError.center = self.center
        textError.center.y -= 50
        self.addSubview(textError)
    }
    
    func viewEmptyError()-> UIView{
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: 50))
        view.backgroundColor = .lightGray
        let label = UILabel.init(frame: CGRect.init(x: 20, y: view.center.y, width: self.frame.size.width - 40, height: 100))
        label.text = "No events has been found"
        label.textColor = .black
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 25.0, weight: .semibold)
        view.addSubview(label)
        return view
    }
}
