 //
//  EquipmentDetailTableViewController.swift
//  Inspection
//
//  Created by apple on 16/1/14.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class EquipmentDetailTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.addGestureRecognizer(UIGestureRecognizer(target: self.tableView, action: "setDelayHourSegue:"))
    }

    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserverForName("needANewPhotoNotification", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            self.takeANewPhoto()
        }
        if equipment != nil {
            equipmentDetail = equipment?.detailArray
            inspectionTaskArray = equipment!.inspectionTaskArray
            tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    var equipment: Equipment?
    var equipmentDetail: EquipmentDetailArrayWithTitle?
    var inspectionTaskArray: [InspectionTask] = []
    var indexPathForlongPressed: NSIndexPath?
    func takeANewPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            if let _ = UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.Camera)?.contains("public.image") {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .Camera
                imagePicker.mediaTypes = ["public.image"]
                imagePicker.delegate = self
                self.presentViewController(imagePicker, animated: false, completion: nil)
            }
        }
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let fileName = "/\(equipment?.info.roomName)\(equipment?.info.name)(room\(equipment?.info.roomID)ID\(equipment?.info.ID))"
            if let path = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent(fileName).path {
                let jpg = UIImageJPEGRepresentation(image, 0.5)
                jpg?.writeToFile(path, atomically: true)
                EquipmentDB().editEquipment(self.equipment!.info.ID, equipmentDetailTitleString: "图片名称", newValue: fileName)
            }
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceivePress press: UIPress) -> Bool {
        print(0)
        return true
    }
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.locationInView(self.tableView)
        
        let indexPath = self.tableView.indexPathForRowAtPoint(point)
        if indexPath?.section == 2 {
            return true
        } else { return false }
    }
    func setDelayHourSegue(sender: UIGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            let point = sender.locationInView(self.tableView)
            indexPathForlongPressed = self.tableView.indexPathForRowAtPoint(point)
            self.performSegueWithIdentifier("editDelayHourSegue", sender: self)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if equipment != nil {
            switch section {
            case 0:
                return equipmentDetail!.count
            case 1:
                return 1
            case 2:
                return inspectionTaskArray.count
            case 3:
                return equipment!.records.count
            default:
                return 0
            }
        } else { return 0}
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("equipmentInfoCell", forIndexPath: indexPath) as! EquipmentDetailTableViewCell
            cell.equipmentInfoTitleLabel.text = equipmentDetail![indexPath.row].title
            cell.equipmentInfoContentLabel.text = equipmentDetail![indexPath.row].info ?? "暂无"
            return cell
            
        case 1:
            var cell = tableView.dequeueReusableCellWithIdentifier("equipmentImageCell", forIndexPath: indexPath) as! EquipmentDetailTableViewCell
            if equipment?.info.imageName != nil {
                if let data = NSData(contentsOfURL: equipment!.imageAbsoluteFilePath!) {
                    if let image = UIImage(data: data) {
                        cell.imageView?.image = image
                        cell.imageHeightConstraint.constant = (UIScreen.mainScreen().bounds.width - 44) / image.size.width * image.size.height
                    }
                } else {
                    cell = tableView.dequeueReusableCellWithIdentifier("equipmentAddImageCell", forIndexPath: indexPath) as! EquipmentDetailTableViewCell
                }
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("equipmentAddImageCell", forIndexPath: indexPath) as! EquipmentDetailTableViewCell
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("equipmentTimeCycleCell", forIndexPath: indexPath) as! EquipmentDetailTableViewCell
            let task = inspectionTaskArray[indexPath.row]
                cell.equipmentInfoTitleLabel.text = task.inspectionTaskName
                if let date = equipment?.records.mostRecentRecordsDir[task.inspectionTaskName] {
                    if equipment?.records.isCompletedForTask(task) == false{
                        cell.equipmentInfoTitleLabel.textColor = UIColor.redColor()
                    }
                    cell.equipmentInfoContentLabel.text = date.datatypeValue
                } else {
                    cell.equipmentInfoContentLabel.text = nil
                    cell.equipmentInfoTitleLabel.textColor = UIColor.redColor()
                }
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("equipmentRecordCell", forIndexPath: indexPath) as! EquipmentDetailTableViewCell
            if let record = equipment?.records.getRecord(indexPath.row) {
                if record.message != nil {
                    cell.recordMessageLabel.text = record.message
                }
                cell.recordTimeLabel.text = record.date.datatypeValue
                cell.recordTypeLabel.text = record.taskType
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("equipmentInfoCell", forIndexPath: indexPath) as! EquipmentDetailTableViewCell
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "  设备信息"
        case 1:
            return "  设备图片"
        case 2:
            return "  维护周期"
        case 3:
            return "  工作记录"
        default:
            return nil
        }
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        switch indexPath.section{ //应该分别定义0，1，2，3，懒了
        case 1 :
            return indexPath
        default :
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if indexPath.section == 3 {
            return true
        } else {
            return false
        }
    }
    
    //MARK:- TODO
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let record = equipment?.records.getRecord(indexPath.row) {
                equipment?.records.delRecord(record)
            }
            self.tableView.reloadData()
        }
    }

    @IBAction func backToEquipmentDetailTable(segue: UIStoryboardSegue) {
        
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEquipmentView" {
            if let DVC = segue.destinationViewController as? ImageViewController {
                DVC.imageURL = equipment?.imageAbsoluteFilePath
            }
        } else if segue.identifier == "equipmentEditSegue" {
            if let DVC = segue.destinationViewController as?  EquipmentEditTableViewController {
                    DVC.equipment = self.equipment
            }
        } else if segue.identifier == "editDelayHourSegue" {
            if let DVC = segue.destinationViewController as? DelayHourEditViewController {
                if indexPathForlongPressed != nil {
                    DVC.task = self.equipment?.inspectionTaskArray[indexPathForlongPressed!.row]
                    DVC.equipment = self.equipment
                }
            }
        }
    }

}
