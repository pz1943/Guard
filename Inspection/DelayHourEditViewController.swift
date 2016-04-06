//
//  DelayHourEditViewController.swift
//  Inspection
//
//  Created by mac-pz on 16/4/6.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class DelayHourEditViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var equipment: Equipment? {
        didSet {
            print("123134")
        }
    }
    var task: InspectionTask?

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
