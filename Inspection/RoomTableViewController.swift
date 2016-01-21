//
//  RoomTableViewController.swift
//  Guard
//
//  Created by apple on 16/1/7.
//  Copyright © 2016年 pz1943. All rights reserved.
//
// 21日修改
//修改图片命名规则
//增加更换图片
//

import UIKit

class RoomTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DB = DBModel.sharedInstance()
        NSNotificationCenter.defaultCenter().addObserverForName("RoomTableNeedRefreshNotification", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.rooms = self.DB!.loadRoomTable()
            self.tableView.reloadData()
        }
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.rightBarButtonItem?.title = "编辑"
    }
    
    override func viewWillAppear(animated: Bool) {
        rooms = DB!.loadRoomTable()
        tableView.reloadData()
    }

    @IBAction func backToRoomTable(segue: UIStoryboardSegue) {
    
    }
    
    
    // MARK: - Table view data source

    var rooms: [(Int, String)] = [ ]
    var DB: DBModel?
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return  rooms.count
        } else {
            return 1
        }
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("roomCell", forIndexPath: indexPath) as! RoomTableViewCell
            cell.roomTitle.text = rooms[indexPath.row].1
            cell.roomID = rooms[indexPath.row].0
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("roomAddCell", forIndexPath: indexPath)
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
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            DB?.delRoom(rooms[indexPath.row].0)
            rooms.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            //MARK: TODO add notification to del
        }
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
        if segue.identifier == "showEquipment" {
            if let NVC = segue.destinationViewController as? UINavigationController {
                if let DVC = NVC.viewControllers.first as? EquipmentTableViewController{
                    if let cell = sender as? RoomTableViewCell {
                        DVC.selectRoomID = cell.roomID
                        DVC.selectRoomName = cell.roomTitle.text
                    }
                }
            }
        }
    }
}
