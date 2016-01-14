//
//  equipmentAddTableViewCell.swift
//  Guard
//
//  Created by apple on 16/1/11.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class EquipmentAddTableViewCell: UITableViewCell, UITextFieldDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        DB = DBModel.sharedInstance()
        equipmentAddTextField.delegate = self
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var DB: DBModel?
    var roomID: Int?
    @IBOutlet weak var equipmentAddTextField: UITextField!
    
    @IBAction func addNew(sender: UIButton) {
        equipmentAddTextField.resignFirstResponder()
        if let equipmentName = equipmentAddTextField.text {
            if equipmentName != "" {
                if roomID != nil {
                    DB?.addEquipment(equipmentName, roomID: roomID!)
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
