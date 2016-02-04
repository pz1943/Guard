//
//  equipmentTableViewController.swift
//  Guard
//
//  Created by apple on 16/1/7.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class EquipmentTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DB = DBModel.sharedInstance()
        NSNotificationCenter.defaultCenter().addObserverForName("EquipmentTableNeedRefreshNotification", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.equipmentArray = self.DB!.loadEquipmentTable(self.selectRoomID!)
            self.tableView.reloadData()
        }
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.rightBarButtonItem?.title = "编辑"
    }
    
    override func viewWillAppear(animated: Bool) {
        if selectRoomID != nil {
            equipmentArray = DB!.loadEquipmentTable(selectRoomID!)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    var DB: DBModel?
    var equipmentArray: [EquipmentBrief] = []
    var selectRoomID: Int?
    var selectRoomName: String?
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return equipmentArray.count
        } else{
            return 1
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("equipmentCell", forIndexPath: indexPath) as! EquipmentTableViewCell
            cell.equipmentTitle.text = equipmentArray[indexPath.row].equipmentName
            cell.equipmentID = equipmentArray[indexPath.row].equipmentID
            if equipmentArray[indexPath.row].isequipmentInspectonCompleted == false {
                cell.DoneFlagImageView.alpha = 0.1
            } else {
                cell.DoneFlagImageView.alpha = 1
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("equipmentAddCell", forIndexPath: indexPath)
            (cell as? EquipmentTableViewCell)?.roomID = selectRoomID
            (cell as? EquipmentTableViewCell)?.roomName = selectRoomName
            return cell
        }
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if indexPath.section == 0 {
            return true
        } else {
            return false
        }
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            if selectRoomID != nil {
                DB?.delEquipment(equipmentArray[indexPath.row].equipmentID)
                equipmentArray.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            //MARK: TODO add notification to del
        }
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "equipmentDetail" {
            if let DVC = segue.destinationViewController as? EquipmentDetailTableViewController {
                if let cell = sender as? EquipmentTableViewCell {
                    DVC.equipmentID = cell.equipmentID
                }
            }
        } else if segue.identifier == "ToQRCodeSegue" {
            if let DVC = segue.destinationViewController as? QRCodeViewController {
                if let equipmentID = (sender as? EquipmentTableViewCell)?.equipmentID {
                    DVC.equipmentID = equipmentID
                }
            }
        }

    }
    
    @IBAction func backToEquipmentTable(segue: UIStoryboardSegue) {
        
    }

}
