//
//  Room.swift
//  Inspection
//
//  Created by apple on 16/3/14.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import Foundation

class room {
    var name: String
    var ID: Int
    var equipmentsArray: [Equipment]
    var isInspectionDone: Bool {
        get {
            for equipment in equipmentsArray {
                if equipment.isInspectionDone == false {
                    return false
                }
            }
            return true
        }
    }
    init(roomID: Int, roomName: String, equipments: [Equipment]){
        self.name = roomName
        self.ID = roomID
        self.equipmentsArray = equipments
    }
    init(roomID: Int, roomName: String) {
        self.name = roomName
        self.ID = roomID
        self.equipmentsArray = []

    }
}