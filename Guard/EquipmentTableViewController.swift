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
        
<<<<<<< HEAD
        DB = DBModel.sharedInstance()
        if selectRoomID != nil {
            equipmentArray = DB!.loadEquipmentTable(selectRoomID!)
        }
        NSNotificationCenter.defaultCenter().addObserverForName("EquipmentTableNeedRefreshNotification", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.equipmentArray = self.DB!.loadEquipmentTable(self.selectRoomID!)
            self.tableView.reloadData()
=======
        let DB = DBModel.sharedInstance()
        if selectRoom != nil {
            equipmentNames = DB.loadEquipmentTable(selectRoom!)
>>>>>>> origin/master
        }
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    // MARK: - Table view data source
<<<<<<< HEAD
    var DB: DBModel?
    var equipmentArray: [(Int, String)] = []
    var selectRoomID: Int?
=======
    
    var equipmentNames: Array<String> = []
    var selectRoom: String?
>>>>>>> origin/master
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
<<<<<<< HEAD
            return equipmentArray.count
=======
            return equipmentNames.count
>>>>>>> origin/master
        } else{
            return 1
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("equipmentCell", forIndexPath: indexPath) as! EquipmentTableViewCell
<<<<<<< HEAD
            cell.equipmentTitle.text = equipmentArray[indexPath.row].1
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("equipmentAddCell", forIndexPath: indexPath)
            (cell as? EquipmentAddTableViewCell)?.roomID = selectRoomID
=======
            cell.equipmentTitle.text = equipmentNames[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("equipmentAddCell", forIndexPath: indexPath) 
>>>>>>> origin/master
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
<<<<<<< HEAD
            if selectRoomID != nil {
                DB?.delEquipment(equipmentArray[indexPath.row].0)
                equipmentArray.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
=======
            equipmentNames.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
>>>>>>> origin/master
            //MARK: TODO add notification to del
        }
    }
    
<<<<<<< HEAD
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        print(indexPath)
    }
=======
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
>>>>>>> origin/master
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    
}
