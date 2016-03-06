//
//  RoomAddTableViewController.swift
//  Inspection
//
//  Created by apple on 16/3/6.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class RoomAddTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        NSNotificationCenter.defaultCenter().addObserverForName("newRoomNameGotNotification", object: self, queue: nil) { (notification) -> Void in
            self.newRoomName = notification.userInfo?["newRoomName"] as? String
            print("2222")
        }
    }

    var newRoomName: String?
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("roomAddCell", forIndexPath: indexPath) as! RoomAddTableViewCell
        cell.titleLabel.text = "新机房名称"
        return cell
    }    

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
        if segue.identifier == "NewRoomGotSegue" {
            if let DVC = segue.destinationViewController as? RoomTableViewController {
                if newRoomName != nil {
                    DVC.addNewRoom(newRoomName!)
                }
            }
        }
    }

}
