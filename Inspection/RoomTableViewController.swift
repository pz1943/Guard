//
//  RoomTableViewController.swift
//  Guard
//
//  Created by apple on 16/1/7.
//  Copyright © 2016年 pz1943. All rights reserved.
//
//


import UIKit

class RoomTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserverForName("RoomTableNeedRefreshNotification", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.rooms = self.DB.loadRoomTable()
            self.tableView.reloadData()
        }
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        editBarButtonItemCopy = self.navigationItem.rightBarButtonItems?[0]
        addBarButtonItemCopy = self.navigationItem.rightBarButtonItems?[1]
        loginBarButtonItemCopy = self.navigationItem.leftBarButtonItem
        refresh()
    }
    override func viewWillAppear(animated: Bool) {
        loadForUser(user)
        tableView.reloadData()
    }
    @IBAction func refresh(sender: UIRefreshControl) {
        refresh()
        sender.endRefreshing()
    }
    
    func refresh() {
        rooms = DB.loadRoomTable()
        loadForUser(user)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @IBAction func backToRoomTable(segue: UIStoryboardSegue) {

    }
    
    func loadForUser(user: User?) {
        if user?.authorty != User.UserPermission.admin {
            if canEditFlag == true {
                self.navigationItem.rightBarButtonItems?.removeAll()
                self.navigationItem.leftBarButtonItem = loginBarButtonItemCopy
                canEditFlag = false
            }
        } else {
            if canEditFlag == false {
                if editBarButtonItemCopy != nil && addBarButtonItemCopy != nil {
                    self.navigationItem.rightBarButtonItems?.append(editBarButtonItemCopy!)
                    self.navigationItem.rightBarButtonItems?.append(addBarButtonItemCopy!)
                    canEditFlag = true
                    self.navigationItem.leftBarButtonItem? = UIBarButtonItem(title: "管理员退出", style: UIBarButtonItemStyle.Plain, target: self, action: "adminExit")
                }
            }
        }
    }
    
    func adminExit() {
        user = UserCenter.defaultUser
        refresh()
    }
    // MARK: - Table view data source
    var editBarButtonItemCopy: UIBarButtonItem?
    var addBarButtonItemCopy: UIBarButtonItem?
    var loginBarButtonItemCopy: UIBarButtonItem?
    var canEditFlag: Bool = true
    var user: User? 
    var rooms: [Room] = [ ]
    var DB = RoomDB()
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return  rooms.count
        } else {
            return 0
        }
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("roomCell", forIndexPath: indexPath) as! RoomTableViewCell
            cell.roomTitle.text = rooms[indexPath.row].name
            cell.roomID = rooms[indexPath.row].ID
            if rooms[indexPath.row].isInspectionDone == false {
                cell.DoneFlagImageView.alpha = 0.1
            } else {
                cell.DoneFlagImageView.alpha = 1
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("roomAddCell", forIndexPath: indexPath)
            return cell
        }

    }


    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {

        if indexPath.section == 0 {
            return canEditFlag
        } else {
            return false
        }
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            DB.delRoom(rooms[indexPath.row].ID)
            rooms.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
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
            if let DVC = segue.destinationViewController as? EquipmentTableViewController{
                if let cell = sender as? RoomTableViewCell {
                    DVC.selectRoomID = cell.roomID
                    DVC.selectRoomName = cell.roomTitle.text
                    DVC.user = self.user
                }
            }
        }
    }
}
