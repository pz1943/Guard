//
//  RoomTableViewController.swift
//  Guard
//
//  Created by apple on 16/1/7.
//  Copyright © 2016年 pz1943. All rights reserved.
//
//


struct Constants {
    static var NavColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    static var GrayColor = UIColor(red: 242, green: 242, blue: 242, alpha: 1.0)
}

import UIKit

class RoomTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.navigationBar.backgroundColor = Constants.NavColor
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        editBarButtonItemCopy = self.navigationItem.rightBarButtonItems?[0]
        addBarButtonItemCopy = self.navigationItem.rightBarButtonItems?[1]
        loginBarButtonItemCopy = self.navigationItem.leftBarButtonItem
        refresh()
        self.user = (self.navigationController?.tabBarController as? RootViewController)?.user
//        initDelayDB()

    }
    deinit {
        print("RoomTableViewController deinit")
    }

    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserverForName("RoomTableNeedRefreshNotification", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.DB.reload()
            self.rooms = self.loadRoomArray()
        }
        loadForUser(user)
        tableView.reloadData()
    }
    @IBAction func refresh(sender: UIRefreshControl) {
        refresh()
        sender.endRefreshing()
    }
    
    func loadRoomArray() -> [Room] {
        return DB.loadRoomTable()
    }
    
    func initDelayDB() {
        let DB = DelayDB()
        let defaultDelayHours = 10.0
        for room in rooms {
            for equipment in room.equipmentsArray {
                for task in equipment.inspectionTaskArray {
                    DB.addDelayForEquipment(equipment.info.ID, inspectionTask: task.inspectionTaskName, hours: defaultDelayHours)
                }
            }
        }
    }
    
    func refresh() {
        DB.reload()
        rooms = loadRoomArray()
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
            cell.room = rooms[indexPath.row]
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
                    DVC.selectRoom = cell.room
                    DVC.user = self.user
                }
            }
        } else if segue.identifier == "newRoomSegue" {
            if let DVC = segue.destinationViewController as? RoomAddTableViewController {
                DVC.roomsArray = self.rooms
            }
        }
    }
}
