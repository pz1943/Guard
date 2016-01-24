//
//  QRCodeTableViewController.swift
//  Inspection
//
//  Created by mac-pz on 16/1/21.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class QRCodeRecordTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        record = InspectionRecord(ID: equipment!.ID, date: nil, type: Inspection.Daily, recordData: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getNewMessage:", name: "newRecordGotNotification", object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    var equipmentID: Int? {
        didSet {
            DB = DBModel.sharedInstance()
            if equipmentID != nil {
                equipment = DB?.loadEquipment(equipmentID!)
            }
        }
    }
    var QRResult: String?
    var equipment: Equipment?
    var DB: DBModel?
    var record: InspectionRecord?

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getNewMessage(notification: NSNotification) {
        if let recordMessage = notification.userInfo?["recordMessage"] {
            record?.message = recordMessage as? String
        }
        
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return Inspection.typeCount
        } else { return 1 }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("InspectionTypeCell", forIndexPath: indexPath)
            cell.textLabel?.text = Inspection.getType()[indexPath.row]
            return cell

        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("RecordCell", forIndexPath: indexPath) as! QRCodeTableViewCell
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "  巡检类型"
        case 1:
            return "  巡检记录"
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 100
        } else { return tableView.rowHeight }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        record?.recordType = Inspection.getType()[indexPath.row]
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "QRDone" {
            DB?.addInspectionRecord(record!)
        }
    }

}
