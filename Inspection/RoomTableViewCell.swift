//
//  RoomTableViewCell.swift
//  Guard
//
//  Created by apple on 16/1/7.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class RoomTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        DB = DBModel.sharedInstance()

    }
    
    @IBOutlet weak var DoneFlagImageView: UIView!
    @IBOutlet weak var roomTitle: UILabel!
    
    var room: Room?
    var DB: DBModel?

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
