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
        if let rootVC = self.tabBarController as? RootViewController {
            self.user = rootVC.user
            self.rooms = rootVC.rooms
        }
        setNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        observer = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "RoomTableNeedRefreshNotification"), object: nil, queue: OperationQueue.main) {
            [unowned self]  (notification) -> Void in
            self.DB.reload()             //db Init
            let roomArray = self.loadRoomArray()
            self.rooms = roomArray
            self.tableView.reloadData()
        }
        if roomTableNeedRefreshFlag {
            let roomArray = self.loadRoomArray()
            self.rooms = roomArray
            self.tableView.reloadData()
        }
        loadForUser(user)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
    }

    func setNavigationBar() {
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.backgroundColor = Constants.NavColor
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationController?.navigationBar.tintColor = UIColor.white
        editBarButtonItemCopy = self.navigationItem.rightBarButtonItems?[0]
        addBarButtonItemCopy = self.navigationItem.rightBarButtonItems?[1]
        loginBarButtonItemCopy = self.navigationItem.leftBarButtonItem
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        refresh()
        sender.endRefreshing()
    }
    
    func loadRoomArray() -> [Room] {
        return DB.loadRoomTable()
    }
    
    func refresh() {
        DB.reload()
        rooms = loadRoomArray()
        loadForUser(user)
        tableView.reloadData()
    }

    @IBAction func backToRoomTable(_ segue: UIStoryboardSegue) {

    }
    
    func loadForUser(_ user: User?) {
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
                    
                    //TODO: without adminExit?
                    self.navigationItem.leftBarButtonItem? = UIBarButtonItem(title: "管理员退出", style: UIBarButtonItemStyle.plain, target: self, action: Selector(("adminExit")))
                }
            }
        }
    }
    
    // MARK: - Table view data source
    var editBarButtonItemCopy: UIBarButtonItem?
    var addBarButtonItemCopy: UIBarButtonItem?
    var loginBarButtonItemCopy: UIBarButtonItem?
    var roomTableNeedRefreshFlag: Bool = false
    var canEditFlag: Bool = true
    var user: User? 
    var rooms: [Room] = [ ]
    var DB = RoomDB()
    var observer: NSObjectProtocol?
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return  rooms.count
        } else {
            return 0
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell", for: indexPath) as! RoomTableViewCell
            cell.roomTitle.text = rooms[(indexPath as NSIndexPath).row].name
            cell.room = rooms[(indexPath as NSIndexPath).row]
            if rooms[(indexPath as NSIndexPath).row].isInspectionDone == false {
                cell.DoneFlagImageView.alpha = 0.1
            } else {
                cell.DoneFlagImageView.alpha = 1
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "roomAddCell", for: indexPath)
            return cell
        }

    }


    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath as NSIndexPath).section == 0 {
            return canEditFlag
        } else {
            return false
        }
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            rooms[(indexPath as NSIndexPath).row].deleteFromDB()
            rooms.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEquipment" {
            if let DVC = segue.destination as? EquipmentTableViewController{
                if let cell = sender as? RoomTableViewCell {
                    DVC.selectRoom = cell.room
                    DVC.user = self.user
                }
            }
        } else if segue.identifier == "newRoomSegue" {
            if let DVC = segue.destination as? RoomAddTableViewController {
                DVC.roomsArray = self.rooms
            }
        }
    }
    //
    //    func initDelayDB() {
    //        let DB = DelayDB()
    //        let defaultDelayHours = 10.0
    //        for room in rooms {
    //            for equipment in room.equipmentsArray {
    //                for task in equipment.inspectionTaskArray {
    //                    DB.addDelayForEquipment(equipment.info.ID, inspectionTask: task.inspectionTaskName, hours: defaultDelayHours)
    //                }
    //            }
    //        }
    //    }

}
