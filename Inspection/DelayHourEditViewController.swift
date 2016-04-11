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
//        dateFormatter = NSDateFormatter()
//        dateFormatter!.dateStyle = .MediumStyle
//        dateFormatter!.timeStyle = .NoStyle
//        dateFormatter!.locale = NSLocale(localeIdentifier: "zh_CN")
        if defaultTime != nil {
            datePicker.setDate(defaultTime!, animated: true)
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var datePicker: UIDatePicker!
//    var dateFormatter: NSDateFormatter?
    var equipment: Equipment?
    var task: InspectionTask?
    var defaultTime: NSDate?

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if task != nil {
            equipment?.records.taskDelayToTime(datePicker.date, task: task!.inspectionTaskName)
        }
    }

}
