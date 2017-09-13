//
//  CycleEditTableViewCell.swift
//  Inspection
//
//  Created by pz1943 on 2017/9/13.
//  Copyright © 2017年 pz1943. All rights reserved.
//

import UIKit

class CycleEditTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var CycleTextField: UITextField!
}
