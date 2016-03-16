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
    var equipment: Equipment
    let DB: DBModel = DBModel.sharedInstance()
    let typeArray: [InspectionType]
    
    init(equipment: Equipment) {
        self.equipment = equipment
        self.typeArray = InspectionTypesArrayForEQ(equipment: equipment).types
    }
    var recordsArray:[Record] {
        get {
            return DB.loadRecordFromEquipmetID(equipment.ID)
        }
    }
    var mostRecentRecordsDir:[String: NSDate] {
        get {
            var recordsDir: [String: NSDate] = [: ]
            for type in typeArray {
                if let record = DB.loadRecentTimeForType(equipment.ID, inspectionType: type.inspectionTypeName) {
                    recordsDir[type.inspectionTypeName] = record.date
                }
            }
            return recordsDir
        }
    }
    
    func isEquipmentCompleted() -> Bool{
        for type in typeArray {
            if isEquipmentCompletedForType(type) == false {
                return false
            }
        }
        return true
    }
    
    func isEquipmentCompletedForType(inspectionType: InspectionType) -> Bool {
        let timeCycleDir = DB.loadInspectionTypeDir()
        if let timeCycle = timeCycleDir.getTimeCycleForEquipment(equipment.type, type: inspectionType.inspectionTypeName){
            if let date = mostRecentRecordsDir[inspectionType.inspectionTypeName] {
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
