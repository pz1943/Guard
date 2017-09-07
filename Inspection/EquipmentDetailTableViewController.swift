 //
//  EquipmentDetailTableViewController.swift
//  Inspection
//
//  Created by apple on 16/1/14.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class EquipmentDetailTableViewController: UITableViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate, UIImagePickerControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(EquipmentDetailTableViewController.setDelayHourSegue(_:))))
        if let roomVC = self.navigationController?.viewControllers[0] as? RoomTableViewController {
            if let rootVC = roomVC.tabBarController as? RootViewController {
                self.user = rootVC.user
            }
        }
    }

    func setDelayHourSegue(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            let point = sender.location(in: self.tableView)
            indexPathForlongPressed = self.tableView.indexPathForRow(at: point)
            if (indexPathForlongPressed as IndexPath?)?.section == 2 {
                self.performSegue(withIdentifier: "editDelayHourSegue", sender: self)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        observer = center.addObserver(forName: Notification.Name(rawValue: "needANewPhotoNotification"), object: nil, queue: OperationQueue.main) { (notification) -> Void in
            self.takeANewPhoto()
        }
        if equipment != nil {
            equipment?.reloadInfo()
            equipmentDetail = equipment?.detailArray
            inspectionTaskArray = equipment!.inspectionTaskArray
            tableView.reloadData()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if observer != nil {
            center.removeObserver(observer!)
        }
    }
    
    var user: User?
    var observer: NSObjectProtocol?
    var center: NotificationCenter = NotificationCenter.default
    var equipment: Equipment?
    var equipmentDetail: EquipmentDetailArrayWithTitle?
    var inspectionTaskArray: [InspectionTask] = []
    var indexPathForlongPressed: IndexPath?
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let fileName = "/\(String(describing: equipment?.info.roomName))\(String(describing: equipment?.info.name))(room\(String(describing: equipment?.info.roomID))ID\(String(describing: equipment?.info.ID)))"
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName).path
            let jpg = UIImageJPEGRepresentation(image, 0.5)
            try? jpg?.write(to: URL(fileURLWithPath: path), options: [.atomic])
            EquipmentDB().editEquipment(self.equipment!.info.ID, equipmentDetailTitleString: "图片名称", newValue: fileName)
            
        }
    }

    func takeANewPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            if let _ = UIImagePickerController.availableMediaTypes(for: UIImagePickerControllerSourceType.camera)?.contains("public.image") {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = ["public.image"]
                imagePicker.delegate = self
                self.present(imagePicker, animated: false, completion: nil)
            }
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath as NSIndexPath).section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "equipmentInfoCell", for: indexPath) as! EquipmentDetailTableViewCell
            cell.equipmentInfoTitleLabel.text = equipmentDetail![(indexPath as NSIndexPath).row].title
            cell.equipmentInfoContentLabel.text = equipmentDetail![(indexPath as NSIndexPath).row].info
            return cell
            
        case 1:
            var cell = tableView.dequeueReusableCell(withIdentifier: "equipmentImageCell", for: indexPath) as! EquipmentDetailTableViewCell
            if equipment?.info.imageName != nil {
                if let data = try? Data(contentsOf: equipment!.imageAbsoluteFilePath! as URL) {
                    if let image = UIImage(data: data) {
                        cell.imageView?.image = image
                        cell.imageHeightConstraint.constant = (UIScreen.main.bounds.width - 44) / image.size.width * image.size.height
                    }
                } else {
                    cell = tableView.dequeueReusableCell(withIdentifier: "equipmentAddImageCell", for: indexPath) as! EquipmentDetailTableViewCell
                }
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "equipmentAddImageCell", for: indexPath) as! EquipmentDetailTableViewCell
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "equipmentTimeCycleCell", for: indexPath) as! EquipmentDetailTableViewCell
            let task = inspectionTaskArray[(indexPath as NSIndexPath).row]
                cell.equipmentInfoTitleLabel.text = task.inspectionTaskName
                if let date = equipment?.records.mostRecentRecordsDir[task.inspectionTaskName] {
                    if equipment?.records.isCompletedForTask(task) == false{
                        cell.equipmentInfoTitleLabel.textColor = UIColor.red
                    } else {
                        cell.equipmentInfoTitleLabel.textColor = UIColor.black
                    }
                    cell.equipmentInfoContentLabel.text = date.datatypeValue
                } else {
                    cell.equipmentInfoContentLabel.text = nil
                    cell.equipmentInfoTitleLabel.textColor = UIColor.red
                }
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "equipmentRecordCell", for: indexPath) as! EquipmentDetailTableViewCell
            if let record = equipment?.records.getRecord((indexPath as NSIndexPath).row) {
                if record.message != nil {
                    cell.recordMessageLabel.text = record.message
                }
                cell.recordTimeLabel.text = record.date.datatypeValue
                cell.recordTypeLabel.text = record.taskType
                cell.recorderLabel.text = record.recorder
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "equipmentInfoCell", for: indexPath) as! EquipmentDetailTableViewCell
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "  设备信息"
        case 1:
            return "  设备图片"
        case 2:
            return "  维护时限"
        case 3:
            return "  工作记录"
        default:
            return nil
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch (indexPath as NSIndexPath).section{ //应该分别定义0，1，2，3，懒了
        case 1 :
            return indexPath
        default :
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if (indexPath as NSIndexPath).section == 3 {
            return true
        } else {
            return false
        }
    }
    
    //MARK:- TODO
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let record = equipment?.records.getRecord((indexPath as NSIndexPath).row) {
                equipment?.records.delRecord(record)
            }
            self.tableView.reloadData()
        }
    }

    @IBAction func backToEquipmentDetailTable(_ segue: UIStoryboardSegue) {
        
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEquipmentView" {
            if let DVC = segue.destination as? ImageViewController {
                DVC.imageURL = equipment?.imageAbsoluteFilePath
                DVC.equipment = equipment
            }
        } else if segue.identifier == "equipmentEditSegue" {
            if let DVC = segue.destination as?  EquipmentEditTableViewController {
                DVC.equipment = self.equipment
            }
        } else if segue.identifier == "editDelayHourSegue" {
            if let NVC = segue.destination as? UINavigationController {
                if let DVC = NVC.viewControllers[0] as? DelayHourEditViewController {
                    if indexPathForlongPressed != nil {
                        if let task = self.equipment?.inspectionTaskArray[(indexPathForlongPressed! as NSIndexPath).row] {
                            DVC.task = task
                            DVC.equipment = self.equipment
                            DVC.defaultTime = self.equipment?.records.getExpectInspectionTime(task.inspectionTaskName)
                            DVC.delayHour = self.equipment?.records.getDelayHourForTask(task.inspectionTaskName)
                            DVC.timeCycle = self.equipment?.records.getTimeCycleForTask(task.inspectionTaskName)
                        }
                    }
                }
            }
        }
    }

}
