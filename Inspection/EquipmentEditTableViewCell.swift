//
//  EquipmentEditTableViewCell.swift
//  Inspection
//
//  Created by apple on 16/1/17.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class EquipmentEditTableViewCell: UITableViewCell, UITextFieldDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        DB = DBModel.sharedInstance()
        // Initialization code
    }
    
    var DB: DBModel?
    var equipment: Equipment?
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
            if  let title = titleLabel.text {
                DB?.editEquipment(equipment!.ID, equipmentDetailTitleString: title, newValue: newText)
            }
        }
    }
    
    
}
