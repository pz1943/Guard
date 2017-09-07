//
//  EquipmentAddTableViewCell.swift
//  Inspection
//
//  Created by apple on 16/3/7.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class EquipmentAddTableViewCell: UITableViewCell, UITextFieldDelegate {

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
//    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        if let newText = textField.text {
//            NotificationCenter.default.post(name: Notification.Name(rawValue: "newEquipmentInfoGotNotification"), object: nil, userInfo: [titleLabel.text!: newText])
//        }
//    }
}
