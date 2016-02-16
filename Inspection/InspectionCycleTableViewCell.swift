//
//  InspectionCycleTableViewCell.swift
//  Inspection
//
//  Created by apple on 16/1/28.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class InspectionCycleTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var timeCycelLabel: UILabel!
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
