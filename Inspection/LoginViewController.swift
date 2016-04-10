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
        self.navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.navigationBar.backgroundColor = Constants.NavColor

    }
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passWordTextField: UITextField!
    
    var user: User?
    
    @IBAction func login(sender: UIButton) {
        if var nameText = userNameTextField.text {
            if nameText == "" {
                nameText = "test"
            }
            if  let pswText = passWordTextField.text {
                user = UserCenter.login(nameText, loginUserPSD: pswText)
                if user != nil {
                    self.performSegueWithIdentifier("loginSegue", sender: nil)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let DVC = segue.destinationViewController as? RootViewController {
                DVC.user = self.user
            }
    }
    
    @IBAction func logout(segue: UIStoryboardSegue) {
        
    }
}
