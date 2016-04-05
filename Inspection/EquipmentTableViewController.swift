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
        DB = EquipmentDB()
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserverForName("EquipmentTableNeedRefreshNotification", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.selectRoom?.equipmentsArray = self.DB!.loadEquipmentTable(self.selectRoom!.ID)
        }
        if selectRoom != nil {
            refresh()
        }
    }
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func refresh() {
        self.loginForUser()
        self.tableView.reloadData()
    }
    
    func loginForUser() {
        if user?.authorty != .admin {
            self.navigationItem.rightBarButtonItems?.removeAll()
            self.canEditFlag = false
        }
    }
    
    // MARK: - Table view data source
    var DB: EquipmentDB?
    var user: User?
    var equipmentArray: [Equipment] {
        get {
            return selectRoom?.equipmentsArray ?? []
        }
    }
    var selectRoom: Room?
    var rightBarButtonItems: UIBarButtonItem?
    var canEditFlag = true
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return equipmentArray.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("equipmentCell", forIndexPath: indexPath) as! EquipmentTableViewCell
        cell.equipmentTitle.text = equipmentArray[indexPath.row].name
        cell.equipment = equipmentArray[indexPath.row]
        if equipmentArray[indexPath.row].inspectionDoneFlag == false {
            cell.DoneFlagImageView.alpha = 0.1
        } else {
            cell.DoneFlagImageView.alpha = 1
        }
        return cell
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if indexPath.section == 0 {
            return canEditFlag
        } else {
            return false
        }
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            if selectRoom != nil {
                DB?.delEquipment(equipmentArray[indexPath.row].ID)
                self.selectRoom?.equipmentsArray.removeAtIndex(indexPath.row)
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
                    DVC.equipment = cell.equipment
                }
            }
        } else if segue.identifier == "ToQRCodeSegue" {
            if let DVC = segue.destinationViewController as? QRCodeForOneEquipmentViewController {
                if let equipment = (sender as? EquipmentTableViewCell)?.equipment {
                    DVC.equipment = equipment
                }
            }
        } else if segue.identifier == "AddEquipmentSegue" {
            if let DVC = segue.destinationViewController as? EquipmentAddTableViewController {
                DVC.room = self.selectRoom
            }
        }
    }
    
    @IBAction func backToEquipmentTable(segue: UIStoryboardSegue) {

    }
}
