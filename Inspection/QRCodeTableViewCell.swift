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

    }
    @IBOutlet weak var recordTextField: UITextField!
    @IBOutlet weak var recordType: UILabel!

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        recordTextField.resignFirstResponder()
        if textField.text != nil {
            NSNotificationCenter.defaultCenter().postNotificationName("newRecordGotNotification", object: nil, userInfo: ["recordMessage": textField.text!])
        }
        return true
    }
}
