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
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.backgroundColor = Constants.NavColor
        self.rooms = DB.loadRoomTable()
        for room in rooms {
            let _ = room.isInspectionDone
        }
        initDelayDB()
    }
    
    func initDelayDB() {
        let DB = DelayDB()
        let defaultDelayHours = 10.0
        for room in rooms {
            for equipment in room.equipmentsArray {
                for task in equipment.inspectionTaskArray {
                    DB.addDelayForEquipment(equipment.info.ID, inspectionTask: task.inspectionTaskName, hours: defaultDelayHours)
                }
            }
        }
    }

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passWordTextField: UITextField!
    
    var user: User?
    var rooms: [Room] = [ ]
    var DB = RoomDB()
    
    @IBAction func login(_ sender: UIButton) {
        if let nameText = userNameTextField.text {
            if  let pswText = passWordTextField.text {
                user = UserCenter.login(nameText, loginUserPSD: pswText)
                if user != nil {
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let DVC = segue.destination as? RootViewController {
            DVC.user = self.user
            DVC.rooms = self.rooms
        }
    }
    
    @IBAction func logout(_ segue: UIStoryboardSegue) {
        
    }
}
