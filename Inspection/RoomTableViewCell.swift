//
//  RoomTableViewCell.swift
//  Guard
//
//  Created by apple on 16/1/7.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class RoomTableViewCell: UITableViewCell, UITextFieldDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        DB = DBModel.sharedInstance()

    }
    
    @IBOutlet weak var DoneFlagImageView: UIView!
    @IBOutlet weak var roomTitle: UILabel!
    @IBOutlet weak var roomAddTextField: UITextField! 
    @IBAction func addNewRoom(sender: UIButton) {
        roomAddTextField.resignFirstResponder()
        if let roomName = roomAddTextField.text {
            DB?.addRoom(roomName)
            roomAddTextField.text = nil
            NSNotificationCenter.defaultCenter().postNotificationName("roomTableNeedRefreshNotification", object: nil)
        }
    }
    
    var roomID: Int?
    var DB: DBModel?

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        roomAddTextField.resignFirstResponder()
        return true
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
