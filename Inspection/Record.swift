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
    var taskType: String
//    var recorder: String
    var message: String?
    //add a new Record
    init(equipmentID: Int, task: String, recordData: String?) {
        self.equipmentID = equipmentID
        self.taskType = task
        self.message = recordData
        self.date = NSDate()
    }
    //load a exist record
    init(recordID: Int, equipmentID: Int, date: NSDate, task: String, recordData: String?) {
        self.recordID = recordID
        self.equipmentID = equipmentID
        self.date = date
        self.taskType = task
        self.message = recordData
    }
}

struct RecordsForEquipment {
    private var equipmentID: Int
    private var equipmentType: String
    private let inspectionTaskDir: InspectionTaskDir = InspectionTaskDir()
    private var inspectionTaskArray: [InspectionTask]

    private let DB: DBModel = DBModel.sharedInstance()

    init(equipmentID: Int, equipmentType: String) {
        self.equipmentID = equipmentID
        self.equipmentType = equipmentType
        self.inspectionTaskArray = inspectionTaskDir.getTaskArray(equipmentType)
    }
    var recordsArray:[Record] {
        get {
            return DB.loadRecordFromEquipmetID(equipmentID)
        }
    }
    var mostRecentRecordsDir:[String: NSDate] {
        get {
            var recordsDir: [String: NSDate] = [: ]
            for type in inspectionTaskArray {
                if let record = DB.loadRecentTimeForType(equipmentID, inspectionTask: type.inspectionTaskName) {
                    recordsDir[type.inspectionTaskName] = record.date
                }
            }
            return recordsDir
        }
    }
    
    private func isEquipmentCompleted() -> Bool{
        for task in inspectionTaskArray {
            if isEquipmentCompletedForTask(task) == false {
                return false
            }
        }
        return true
    }
    
    private func isEquipmentCompletedForTask(inspectionTask: InspectionTask) -> Bool {
        if let timeCycle = inspectionTaskDir.getTimeCycleForEquipment(equipmentType, task: inspectionTask.inspectionTaskName){
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
