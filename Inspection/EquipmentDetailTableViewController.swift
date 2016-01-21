//
//  EquipmentDetailTableViewController.swift
//  Inspection
//
//  Created by apple on 16/1/14.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class EquipmentDetailTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.estimatedRowHeight = tableView.rowHeight
//        tableView.rowHeight = UITableViewAutomaticDimension
        DB = DBModel.sharedInstance()
        NSNotificationCenter.defaultCenter().addObserverForName("needANewPhotoNotification", object: nil, queue: nil) { (notification) -> Void in
            self.takeANewPhoto()
        }
    }

    override func viewWillAppear(animated: Bool) {
        if equipmentID != nil {
            equipment = DB!.loadEquipment(equipmentID!)
            if equipment != nil {
                equipmentDetail = equipment!.detailArray
                tableView.reloadData()
            }
        }
    }
    var DB: DBModel?
    var equipment: Equipment?
    var equipmentID: Int?
    var equipmentDetail: Equipment.EquipmentDetailArray = [ ]
    var imageHeight: CGFloat = 0
    func takeANewPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let x = UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.Camera)
            print(x)

            if let _ = UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.Camera)?.contains("public.image") {
                let imagePicker = UIImagePickerController()
                imagePicker.sourceType = .Camera
                imagePicker.mediaTypes = ["public.image"]
                imagePicker.delegate = self
                self.presentViewController(imagePicker, animated: false, completion: nil)
            }
        }
    }
    /**
     本次增加了图片的命名规则。
     
     - parameter picker: picker description
     - parameter info:   info description
     */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let fileName = "/\(equipment?.roomName)\(equipment?.name)(room\(equipment?.roomID)ID\(equipment?.ID))"
            if let path = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent(fileName).path {
                let jpg = UIImageJPEGRepresentation(image, 0.5)
                jpg?.writeToFile(path, atomically: true)
                DB?.editEquipment(self.equipment!.ID, equipmentDetailTitleString: "图片名称", newValue: fileName)
            }
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if equipment != nil {
                return equipment!.detailArray.count
            } else { return 0 }
        case 1:
            return 1
//        case 2:
//            return 6
//        case 3:
//            //MARK: TODO Change to record count?
//            return 100
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        

        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("equipmentInfoCell", forIndexPath: indexPath) as! EquipmentDetailTableViewCell
            cell.equipmentInfoTitleLabel.text = equipmentDetail[indexPath.row].title.rawValue
            cell.equipmentInfoContentLabel.text = equipmentDetail[indexPath.row].info
            return cell
            
        case 1:
            if equipment?.imageName != nil {
                let cell = tableView.dequeueReusableCellWithIdentifier("equipmentImageCell", forIndexPath: indexPath) as! EquipmentDetailTableViewCell
                if let data = NSData(contentsOfURL: equipment!.imageAbsoluteFilePath!) {
                    if let image = UIImage(data: data) {
                        cell.imageView?.image = image
                        imageHeight = (cell.contentView.bounds.width - 32 ) / image.size.width * image.size.height
                    }
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("equipmentAddImageCell", forIndexPath: indexPath) as! EquipmentDetailTableViewCell
                return cell
            }
//        case 2:
//            return 6
//        case 3:
//            //MARK: TODO Change to record count?
//            return 100
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 {
            if equipment?.imageName != nil {
                return imageHeight
            } else { return 40 }
        } else { return 40 }
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
            if let NVC = segue.destinationViewController as?  UINavigationController {
                if let DVC = NVC.childViewControllers.first as? EquipmentEditTableViewController {
                    DVC.equipment = self.equipment
                }
            }
        }
    }

}
