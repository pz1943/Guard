//
//  QRCodeTableViewController.swift
//  Inspection
//
//  Created by mac-pz on 16/1/21.
//  Copyright © 2016年 pz1943. All rights reserved.
//
//  git test

import UIKit

class QRCodeForAnyEquipmentTableViewController: QRCodeRecordTableViewController {

}

class QRCodeRecordTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        taskArray = equipment!.inspectionTaskArray
        initRecord()
        selectFirst()
        self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.title = equipment!.info.name
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.backgroundColor = Constants.NavColor
        let tapGr = UITapGestureRecognizer(target: self, action: #selector(QRCodeRecordTableViewController.backGroundPressed(_:)))
        tapGr.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tapGr)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(QRCodeRecordTableViewController.getNewMessage(_:)), name: NSNotification.Name(rawValue: "newRecordGotNotification"), object: nil)

    }

    @IBAction func backGroundPressed(_ sender: UITapGestureRecognizer) {
        message = textFieldCell?.recordTextField.text
        textFieldCell?.recordTextField.resignFirstResponder()
    }

    var equipment: Equipment?
    var record: Record?
    var taskArray: [InspectionTask] = []
    var user: User!
    var message: String? {
        didSet {
            record?.message = message
        }
    }
    var textFieldCell: QRCodeTableViewCell?

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initRecord(){
        if let rootVC = self.presentingViewController as? RootViewController {
            self.user = rootVC.user
            record = Record(equipmentID: equipment!.info.ID, task: taskArray.first?.inspectionTaskName ?? "无", recorder: user.name, recordData: nil, recordDate: nil)
        } else {
            if let roomVC = self.navigationController?.viewControllers[0] as? RoomTableViewController {
                if let rootVC = roomVC.tabBarController as? RootViewController {
                    self.user = rootVC.user
                    record = Record(equipmentID: equipment!.info.ID, task: taskArray.first?.inspectionTaskName ?? "无", recorder: user.name, recordData: nil, recordDate: nil)
                }
            }
        }
    }
    
    func selectFirst() {
        tableView.selectRow(at: IndexPath(row: 0, section: 1), animated: false, scrollPosition: UITableViewScrollPosition.none)
    }
    func getNewMessage(_ notification: Notification) {
        if let recordMessage = (notification as NSNotification).userInfo?["recordMessage"] {
            message = recordMessage as? String
        }
    }
    
    func reloadTableView() {
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(QRCodeRecordTableViewController.timerReloadTableView), userInfo: nil, repeats: false)
    }
    func timerReloadTableView() {
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 1 {
            return taskArray.count
        } else { return 1 }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "InspectionTypeCell", for: indexPath) as! QRCodeTableViewCell
            cell.textLabel?.text = taskArray[(indexPath as NSIndexPath).row].inspectionTaskName
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath) as! QRCodeTableViewCell
            cell.recordType.text = record?.taskType
            cell.recordTextField.text = record?.message
            textFieldCell = cell
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "  巡检类型"
        case 0:
            return "  巡检记录"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 100
        } else { return tableView.rowHeight }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        if (indexPath as NSIndexPath).section == 1 {
            record?.taskType = taskArray[(indexPath as NSIndexPath).row].inspectionTaskName
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .top)
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "QRDone" {
            message = textFieldCell?.recordTextField.text
            textFieldCell?.recordTextField.resignFirstResponder()
            equipment?.records.addRecord(record!)
        }
    }
}
