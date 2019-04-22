//
//  UserTableViewCell.swift
//  GoogleCalenderDemo
//
//  Created by Anil Kumar on 12/04/19.
//  Copyright © 2019 Busywizzy. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var buttonAccept: UIButton!
    @IBOutlet weak var labelUserName: UILabel!
    
    @IBOutlet weak var buttonRemove: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
