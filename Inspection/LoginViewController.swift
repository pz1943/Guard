//
//  LoginViewController.swift
//  Inspection
//
//  Created by apple on 16/3/8.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationItem.title = "用户登录"
    }
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passWordTextField: UITextField!
    
    var user: User?
    
    @IBAction func login(sender: UIButton) {
        if let nameText = userNameTextField.text {
            if  let pswText = passWordTextField.text {
                user = UserCenter.login(nameText, loginUserPSD: pswText)
                if user != nil {
                    self.performSegueWithIdentifier("loginCompleteSegue", sender: nil)
                }
            }
        }
    }
    
    @IBAction func loginCancel(sender: UIButton) {
        user = UserCenter.defaultUser
        self.performSegueWithIdentifier("loginCompleteSegue", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let DVC = segue.destinationViewController as? RoomTableViewController {
            DVC.user = self.user
        }
    }    
}
