//
//  InspectionCycleEditTableViewController.swift
//  Inspection
//
//  Created by pz1943 on 2017/9/6.
//  Copyright © 2017年 pz1943. All rights reserved.
//


import UIKit

class EquipmentTypeEditTableViewController: UITableViewController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    var equipmentTypes: [String] = []
    var timeCycleDir: InspectionTaskDir? {
        didSet {
            if timeCycleDir != nil {
                equipmentTypes = timeCycleDir!.equipmentTypeArray
            }
        }
    }
    private var selectedEquipmentType: String = ""
/*
    @IBAction func segueBack(_ sender: UIBarButtonItem) {
        //TODO: shouldn't save edit when cancel
        self.tableView.reloadData()
        self.performSegue(withIdentifier: "backToDetail", sender: self)
    }
    @IBAction func editDone(_ sender: UIBarButtonItem) {
        self.tableView.reloadData()
        self.performSegue(withIdentifier: "backToDetail", sender: self)
    }
 */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backToEquipmentTypeEdit(_ segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - Table view data source
//    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
//    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return equipmentTypes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "equipmentTypeEditCell", for: indexPath) as! EquipmentTypeEditTableViewCell
        cell.equipmentTypeName.text = self.equipmentTypes[indexPath.row]
//        cell.equipment = self.equipment
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedEquipmentType = self.equipmentTypes[indexPath.row]
    }
    // TODO: -
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
//            rooms[(indexPath as NSIndexPath).row].deleteFromDB()
//            rooms.remove(at: (indexPath as NSIndexPath).row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "InspectionTypeEdit" {
            if let DVC = segue.destination as? TypeAddTableViewController {
                if timeCycleDir != nil {
                    DVC.timeCycleArr = timeCycleDir!.getTaskArray(selectedEquipmentType)
                }
            }
        }
    }

}
