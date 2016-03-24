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

    private let DB = RecordDB()
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
    
    var count: Int {
        return recordsArray.count
    }
}
class RecordDB {
    private var DB: DBModel
    private var user: Connection
    private var recordTable: Table
    
    private let equipmentIDExpression = Expression<Int>(ExpressionTitle.EQID.description)
    private let recordIDExpression = Expression<Int>(ExpressionTitle.RecordID.description)
    private let recordMessageExpression = Expression<String?>(ExpressionTitle.RecordMessage.description)
    private let inspectionTaskNameExpression = Expression<String>(ExpressionTitle.InspectionTaskName.description)
    private let recordDateExpression = Expression<NSDate>(ExpressionTitle.RecordDate.description)
    
    init() {
        self.DB = DBModel.sharedInstance()
        self.user = DB.getUser()
        self.recordTable = Table("recordTable")
        
        try! user.run(recordTable.create(ifNotExists: true) { t in
            t.column(recordIDExpression, primaryKey: true)
            t.column(equipmentIDExpression)
            t.column(inspectionTaskNameExpression)
            t.column(recordMessageExpression)
            t.column(recordDateExpression)
            })
    }
    
    func addRecord(record: Record) {
        let insert = recordTable.insert(self.recordMessageExpression <- record.message,
            self.inspectionTaskNameExpression <- record.taskType,
            self.equipmentIDExpression <- record.equipmentID,
            self.recordDateExpression <- record.date)
        do {
            try user.run(insert)
        } catch let error as NSError {
            print(error)
        }
    }
    
    func delRecord(recordID: Int) {
        let alice = recordTable.filter(self.recordIDExpression == recordID)
        do {
            try user.run(alice.delete())
        } catch let error as NSError {
            print(error)
        }
    }
    //MARK: - low efficiency when records became more.
    func loadRecordFromEquipmetID(equipmentID: Int) -> [Record]{
        let alice = recordTable.filter(self.equipmentIDExpression == equipmentID)
        var array: [Row] = []
        var recordArray: [Record] = []
        do {
            let rows = try user.prepare(alice)
            array = Array(rows)
        } catch let error as NSError {
            print(error)
        }
        for row in array {
            let record = Record(recordID: row[self.recordIDExpression], equipmentID: row[self.equipmentIDExpression], date: row[recordDateExpression], task: row[inspectionTaskNameExpression], recordData: row[recordMessageExpression])
            recordArray.insert(record, atIndex: 0)
        }
        return recordArray
    }
    func loadRecordFromRecordID(recordID: Int) -> Record {
        let alice = recordTable.filter(self.recordIDExpression == recordID)
        let row = Array(try! user.prepare(alice)).first!
        let record = Record(recordID: row[self.recordIDExpression], equipmentID: row[self.equipmentIDExpression], date: row[recordDateExpression], task: row[inspectionTaskNameExpression], recordData: row[recordMessageExpression])
        return record
        
    }
    
    func loadRecentTimeForType(equipmentID: Int, inspectionTask: String) -> Record? {
        let alice = recordTable.filter(self.equipmentIDExpression == equipmentID && self.inspectionTaskNameExpression == inspectionTask)
        if let lastRecordID = user.scalar(alice.select(recordIDExpression.max)) {
            let record = loadRecordFromRecordID(lastRecordID)
            return record
        } else {
            return nil
        }
    }
}
