//
//  EquipmentDetailTableViewController.swift
//  Inspection
//
//  Created by apple on 16/1/14.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class EquipmentDetailTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DB = DBModel.sharedInstance()
        if equipmentID != nil {
            equipmentDetail = DB!.loadEquipment(equipmentID!)
        }
    }
    var DB: DBModel?
    var equipmentDetail: [(String, String?)] = [ ]
    var equipmentID: Int?
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return equipmentDetail.count
        case 1:
            return 1
        case 2:
            return 6
        case 3:
            //MARK: TODO Change to record count?
            return 100
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("equipmentInfoCell", forIndexPath: indexPath) as! EquipmentDetailTableViewCell

        switch indexPath.section {
        case 0:
            cell.equipmentInfoContentLabel.text = equipmentDetail[indexPath.row].0
            cell.equipmentInfoTitleLabel.text = equipmentDetail[indexPath.row].1
            return cell
//        case 2:
//            return 6
//        case 3:
//            //MARK: TODO Change to record count?
//            return 100
        default:
            return cell
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
