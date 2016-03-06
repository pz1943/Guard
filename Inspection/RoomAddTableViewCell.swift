//
//  RoomAddTableViewCell.swift
//  Inspection
//
//  Created by apple on 16/3/6.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class RoomAddTableViewCell: UITableViewCell, UITextFieldDelegate{
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoTextField: UITextField!
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        infoTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let newText = textField.text {
            NSNotificationCenter.defaultCenter().postNotificationName("newRoomNameGotNotification", object: nil, userInfo: ["newRoomName": newText])
        }
    }
}
