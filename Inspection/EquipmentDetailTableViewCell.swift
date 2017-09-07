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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBOutlet weak var recordMessageLabel: UILabel! {
        didSet{
            recordMessageLabel.numberOfLines = 0
        }
    }
    @IBOutlet weak var recordTimeLabel: UILabel!
    @IBOutlet weak var recordTypeLabel: UILabel!
    @IBOutlet weak var recorderLabel: UILabel!

    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBAction func photo(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "needANewPhotoNotification"), object: nil)

    }
}
