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

        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    var equipment: Equipment?
    @IBOutlet weak var equipmentTitle: UILabel!
    @IBOutlet weak var DoneFlagImageView: UIImageView!

}
