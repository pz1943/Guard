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
        // Initialization code
    }
    @IBOutlet weak var roomTitle: UILabel!
<<<<<<< HEAD
    
    var roomID: Int?
=======
    @IBOutlet weak var roomDetail: UILabel!
    
>>>>>>> origin/master
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
