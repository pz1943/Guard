//
//  AccountTypeSelectViewController.swift
//  Inspection
//
//  Created by apple on 16/5/3.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class AccountTypeSelectViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        instructionTextView.text = instructionText[0]

        // Do any additional setup after loading the view.
    }
    
    var accountType: User.UserPermission = User.UserPermission.daily
    let instructionText = [
        "1、用于机房设备的日常巡检;\n2、可以管理50台以下的设备;\n3、不能增删设备;\n4、需要注册码.",
        "1、用于机房设备的增减变更，信息维护;\n2、可以管理50台以下的设备;\n3、可以增删设备;\n4、同普通帐号共用注册码.",
        "1、用于测试试用;\n2、可以管理10台以下的设备;\n3、可以增删设备;\n4、无需注册码."    ]
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    @IBOutlet weak var typeSegment: UISegmentedControl!
    @IBAction func changeAccountType(sender: UISegmentedControl) {
        instructionTextView.text = instructionText[sender.selectedSegmentIndex]
        switch sender.selectedSegmentIndex {
        case 0:
            accountType = User.UserPermission.daily
            break
        case 1:
            accountType = User.UserPermission.admin
            break
        case 2:
            accountType = User.UserPermission.test
            break
        default:
            break
        }
    }

    @IBOutlet weak var instructionTextView: UITextView!
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let NVC = segue.destinationViewController as? UINavigationController {
            if let DVC = NVC.viewControllers[0] as? AccountRegistViewController {
                DVC.accountType = self.accountType
            }
        }
    }

}
