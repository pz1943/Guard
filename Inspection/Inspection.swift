//
//  Inspection.swift
//  Inspection
//
//  Created by mac-pz on 16/2/4.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import Foundation
import SQLite

struct InspectionTask {
    var equipmentType: String
    var inspectionTaskName: String
    var inspectionCycle: Double
}

struct InspectionTaskDir {
    private var dir: [String: [InspectionTask]] = [: ]
    private let DB = DBModel.sharedInstance()
    init() {
        self.dir = DB.loadInspectionTaskDir()
    }
    
    var equipmentTypeArray: [String] {
        get {
            return Array(dir.keys)
        }
    }
    
    var equipmentTypeCount: Int {
        get {
            return equipmentTypeArray.count
        }
    }
    
    func getTaskArray(equipmentType: String?) -> [InspectionTask]{
        if equipmentType != nil {
            if let arr = dir[equipmentType!] {
                return arr
            }
        }
        return []
    }
    
    subscript(index: Int?) -> [InspectionTask] {
        get {
            if index != nil {
                let equipmentType = equipmentTypeArray[index!]
                if let types =  dir[equipmentType] {
                    return types
                } else {
                    return []
                }
            } else {
                return []
            }
        }
    }
    
    func getTimeCycleForEquipment(equipmentType: String, type: String) -> Double? {
        var cycle: Double = 0.0
        if let typeArray = dir[equipmentType] {
            let _ = typeArray.map({
                if $0.equipmentType == type {
                    cycle = $0.inspectionCycle
                }
            })
            return cycle
        } else {
            return nil
        }
    }
}

struct InspectionDelayDir {
    private var dir: [String: Int] = [: ]
    private let DB = DBModel.sharedInstance()
    init(equipmentID: Int) {
        self.dir = DB.loadInspectionDelayDir(equipmentID)
    }
    
}


