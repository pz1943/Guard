//
//  QRCodeTableViewCell.swift
//  Inspection
//
//  Created by mac-pz on 16/1/21.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class QRCodeTableViewCell: UITableViewCell, UITextFieldDelegate{

    override func awakeFromNib() {
        super.awakeFromNib()
        DB = DBModel.sharedInstance()

        // Initialization code
    }
    var DB: DBModel?
    var equipment: Equipment?
    @IBOutlet weak var recordTextField: UITextField!

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        recordTextField.resignFirstResponder()
        DB?.addInspectionRecord(textField.text, equipmentID: equipment?.ID)
        return true
    }
    

}
