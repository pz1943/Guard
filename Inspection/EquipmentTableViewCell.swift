//
//  EquipmentTableViewCell.swift
//  Guard
//
//  Created by apple on 16/1/7.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class EquipmentTableViewCell: UITableViewCell, UITextFieldDelegate{

    override func awakeFromNib() {
        super.awakeFromNib()
        DB = DBModel.sharedInstance()

        // Initialization code
    }

    @IBOutlet weak var equipmentTitle: UILabel!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    var DB: DBModel?
    var roomID: Int?
    var roomName: String?
    var equipmentID: Int?
    @IBOutlet weak var equipmentAddTextField: UITextField!
    
    @IBAction func addNew(sender: UIButton) {
        equipmentAddTextField.resignFirstResponder()
        if let equipmentName = equipmentAddTextField.text {
            if equipmentName != "" {
                if roomID != nil {
                    DB?.addEquipment(equipmentName, roomID: roomID!, roomName: roomName!)
                    equipmentAddTextField.text = nil
                    NSNotificationCenter.defaultCenter().postNotificationName("EquipmentTableNeedRefreshNotification", object: nil)
                }
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        equipmentAddTextField.resignFirstResponder()
        return true
    }

}
