//
//  equipmentDetailTableViewCell.swift
//  Guard
//
//  Created by apple on 16/1/12.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class EquipmentDetailTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var equipmentInfoTitleLabel: UILabel!
    @IBOutlet weak var equipmentInfoContentLabel: UILabel!
    
    @IBOutlet weak var equipmentImageView: UIImageView!
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func photo(sender: UIButton) {
        NSNotificationCenter.defaultCenter().postNotificationName("needANewPhotoNotification", object: nil)

    }
}
