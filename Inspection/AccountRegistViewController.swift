//
//  AccountRegistViewController.swift
//  Inspection
//
//  Created by apple on 16/5/4.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class AccountRegistViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(accountType)
        // Do any additional setup after loading the view.
    }
    
    var accountType: User.UserPermission?
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
