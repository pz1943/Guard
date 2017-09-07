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
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.backgroundColor = Constants.NavColor
        if defaultTime != nil {
            datePicker.setDate(defaultTime!, animated: true)
        }
        if timeCycle != nil {
            timeCycleLabel.text = "\(timeCycle!)"
        }
        if delayHour != nil {
            delayHourLabel.text = "\(delayHour!)"
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
    var defaultTime: Date?
    var timeCycle: Double?
    var delayHour: Double?

    @IBOutlet weak var timeCycleLabel: UILabel!
    @IBOutlet weak var delayHourLabel: UILabel!
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "delayHourSetDone" {
            if task != nil {
                equipment?.records.taskDelayToTime(datePicker.date, task: task!.inspectionTaskName)
            }
        }
    }

}
