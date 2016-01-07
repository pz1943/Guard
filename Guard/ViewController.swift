//
//  ViewController.swift
//  Guard
//
//  Created by apple on 16/1/4.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DB = DBModel.sharedInstance()
    }
    var DB: DBModel?
    
}

