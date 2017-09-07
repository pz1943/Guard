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
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {

        if needRefreshDataFlag == true {
            self.selectRoom?.equipmentsArray = self.DB!.loadEquipmentTable(self.selectRoom!.ID).map({ (info) -> Equipment in
                Equipment(info: info)
            })
            self.tableView.reloadData()
            needRefreshDataFlag = false
        }
        if selectRoom != nil {
            refresh()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        if observer != nil {
            NotificationCenter.default.removeObserver(observer!)
        }
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
    var observer: NSObjectProtocol?
    var needRefreshDataFlag = false
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return equipmentArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "equipmentCell", for: indexPath) as! EquipmentTableViewCell
        cell.equipmentTitle.text = equipmentArray[(indexPath as NSIndexPath).row].info.name
        cell.equipment = equipmentArray[(indexPath as NSIndexPath).row]
        if equipmentArray[(indexPath as NSIndexPath).row].inspectionDoneFlag == false {
            cell.DoneFlagImageView.alpha = 0.1
        } else {
            cell.DoneFlagImageView.alpha = 1
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if (indexPath as NSIndexPath).section == 0 {
            return canEditFlag
        } else {
            return false
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if selectRoom != nil {
                DB?.delEquipment(equipmentArray[(indexPath as NSIndexPath).row].info.ID)
                self.selectRoom?.equipmentsArray.remove(at: (indexPath as NSIndexPath).row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            //MARK: TODO add notification to del
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "equipmentDetail" {
            if let DVC = segue.destination as? EquipmentDetailTableViewController {
                if let cell = sender as? EquipmentTableViewCell {
                    DVC.equipment = cell.equipment
                }
            }
        } else if segue.identifier == "ToQRCodeSegue" {
            if let DVC = segue.destination as? QRCodeForOneEquipmentViewController {
                if let equipment = (sender as? EquipmentTableViewCell)?.equipment {
                    DVC.equipment = equipment
                }
            }
        } else if segue.identifier == "AddEquipmentSegue" {
            if let DVC = segue.destination as? EquipmentAddTableViewController {
                DVC.room = self.selectRoom
            }
        }
    }
    
    @IBAction func backToEquipmentTable(_ segue: UIStoryboardSegue) {

    }
}
