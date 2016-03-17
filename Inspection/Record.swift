//
//  Record.swift
//  Inspection
//
//  Created by apple on 16/3/16.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import Foundation
import SQLite

struct Record {
    var ID: Int {
        get {
            return recordID!
        }
    }
    private var recordID: Int?
    var equipmentID: Int
    var date: NSDate
    var recordType: String
    var message: String?
    //add a new Record
    init(equipmentID: Int, type: String, recordData: String?) {
        self.equipmentID = equipmentID
        self.recordType = type
        self.message = recordData
        self.date = NSDate()
    }
    //load a exist record
    init(recordID: Int, equipmentID: Int, date: NSDate, type: String, recordData: String?) {
        self.recordID = recordID
        self.equipmentID = equipmentID
        self.date = date
        self.recordType = type
        self.message = recordData
    }
}

struct RecordsForEquipment {
    private var equipmentID: Int
    private var equipmentType: String
    private var typeArray: [InspectionTask]
    
    private let inspectionTaskDir = InspectionTaskDir()
    private let DB: DBModel = DBModel.sharedInstance()

    init(equipmentID: Int, equipmentType: String) {
        self.equipmentID = equipmentID
        self.equipmentType = equipmentType
        self.typeArray = inspectionTaskDir.getTaskArray(equipmentType)
    }
    var recordsArray:[Record] {
        get {
            return DB.loadRecordFromEquipmetID(equipmentID)
        }
    }
    var mostRecentRecordsDir:[String: NSDate] {
        get {
            var recordsDir: [String: NSDate] = [: ]
            for type in typeArray {
                if let record = DB.loadRecentTimeForType(equipmentID, inspectionTask: type.inspectionTaskName) {
                    recordsDir[type.inspectionTaskName] = record.date
                }
            }
            return recordsDir
        }
    }
    
    private func isEquipmentCompleted() -> Bool{
        for type in typeArray {
            if isEquipmentCompletedForType(type) == false {
                return false
            }
        }
        return true
    }
    
    private func isEquipmentCompletedForType(inspectionTask: InspectionTask) -> Bool {
        if let timeCycle = inspectionTaskDir.getTimeCycleForEquipment(equipmentType, type: inspectionTask.inspectionTaskName){
            if let date = mostRecentRecordsDir[inspectionTask.inspectionTaskName] {
                if -date.timeIntervalSinceNow.datatypeValue > Double(timeCycle) * 24 * 3600{
                    return false
                }
            } else {
                return false
            }
        }
        return true
    }
    
    var completedFlag: Bool {
        return isEquipmentCompleted()
    }
}
