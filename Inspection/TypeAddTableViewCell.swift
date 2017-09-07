//
//  TypeAddTableViewCell.swift
//  Inspection
//
//  Created by pz1943 on 2017/9/6.
//  Copyright © 2017年 pz1943. All rights reserved.
//

import UIKit

class TypeAddTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var infoTextField: UITextField!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        infoTextField.resignFirstResponder()
        return true
    }
        // Configure the view for the selected state
}


