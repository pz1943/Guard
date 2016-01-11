//
//  addRoomTableViewCell.swift
//  Guard
//
//  Created by apple on 16/1/10.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class roomAddTableViewCell: UITableViewCell, UITextFieldDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        DB = DBModel.sharedInstance()
        roomAddTextField.delegate = self
        // Initialization code
    }
    
    var DB: DBModel?
    @IBOutlet weak var roomAddTextField: UITextField!
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func addNewRoom(sender: UIButton) {
        roomAddTextField.resignFirstResponder()
        if let roomName = roomAddTextField.text {
            DB?.addRoom(roomName)
            roomAddTextField.text = nil
            NSNotificationCenter.defaultCenter().postNotificationName("roomTableNeedRefreshNotification", object: nil)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        roomAddTextField.resignFirstResponder()
        return true
    }
}
