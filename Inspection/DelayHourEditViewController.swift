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
        dateFormatter = NSDateFormatter()
        dateFormatter!.dateStyle = .MediumStyle
        dateFormatter!.timeStyle = .NoStyle
        dateFormatter!.locale = NSLocale(localeIdentifier: "zh_CN")

        print("viewDidLoad")
        print(datePicker.date)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBInspectable
    @IBOutlet weak var datePicker: UIDatePicker!
    var dateFormatter: NSDateFormatter?
    var equipment: Equipment?
    var task: InspectionTask?

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(datePicker.date)
        if task != nil {
            equipment?.records.taskDelayToTime(datePicker.date, task: task!.inspectionTaskName)
        }
    }

}
