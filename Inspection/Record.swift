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
    init(equipmentID: Int, task: String, recordData: String?, recordDate: NSDate?) {
        self.equipmentID = equipmentID
        self.taskType = task
        self.message = recordData
        if recordDate == nil {
            self.date = NSDate()
        } else {
            self.date = recordDate!
        }
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

class RecordsForEquipment {
    private var info: EquipmentInfo
    private let inspectionTaskDir: InspectionTaskDir = InspectionTaskDir()
    private var inspectionTaskArray: [InspectionTask]

    private let DB = RecordDB()
    init(info: EquipmentInfo, taskArray: [InspectionTask]) {
        self.info = info
        self.inspectionTaskArray = taskArray
        self.delayHourDirCache = DelayHourDir(info: self.info, taskArray: self.inspectionTaskArray)
        self.recentRecoredsDir = getRecentRecords()
    }
    
    deinit {
        print("deinit record \(info.ID)")
    }
    
    private var recentRecoredsDir: [String: NSDate] = [: ]
    private var recentNeedRefresh: Bool = true
    var mostRecentRecordsDir: [String: NSDate] {
        get {
            if recentNeedRefresh == true {
                recentRecoredsDir = getRecentRecords()
                recentNeedRefresh = false
            }
            return recentRecoredsDir
        }
    }
    
    private var completedFlagNeedRefresh: Bool = true
    private var completedFlagCache: Bool = false
    var completedFlag: Bool {
        if completedFlagNeedRefresh == true {
            completedFlagCache = isEquipmentCompleted()
            completedFlagNeedRefresh = false
            return completedFlagCache
        } else {
            return completedFlagCache
        }
    }

    private var delayHourDirCache: DelayHourDir
    private var delayHourNeedRefreshFlag: Bool = false
    private var delayHourDir: DelayHourDir {
        get {
            if delayHourNeedRefreshFlag == false {
                return delayHourDirCache
            } else {
                delayHourNeedRefreshFlag = false
                delayHourDirCache = DelayHourDir(info: self.info, taskArray: self.inspectionTaskArray)
                return delayHourDirCache
            }
        }
    }
    
    private func getRecentRecords() -> [String: NSDate]{
        var recent: [String: NSDate] = [: ]
        for type in inspectionTaskArray {
            if let record = DB.loadRecentTimeForType(info.ID, inspectionTask: type.inspectionTaskName) {
                recent[type.inspectionTaskName] = record.date
            }
        }
        return recent
    }       
    
    private func isEquipmentCompleted() -> Bool{
        for task in inspectionTaskArray {
            if CompletedForTask(task) == false {
                return false
            }
        }
        return true
    }
    
    private func CompletedForTask(inspectionTask: InspectionTask) -> Bool {
        if let timeCycle = inspectionTaskDir.getTimeCycleForEquipment(info.type, taskName: inspectionTask.inspectionTaskName){
            if let date = mostRecentRecordsDir[inspectionTask.inspectionTaskName] {
                if let delayHour = delayHourDir[inspectionTask.inspectionTaskName] {
                    let timeCycleInSeconds = Double(timeCycle) * 86400 + Double(delayHour) * 3600
                    if -date.timeIntervalSinceNow.datatypeValue > timeCycleInSeconds {
                        return false
                    }
                }
            } else {
                return false
            }
        }
        return true
    }
    
    var count: Int {
        return DB.countForEQ(info.ID)
    }
    
    func isCompletedForTask(inspectionTask: InspectionTask) -> Bool {
        return self.CompletedForTask(inspectionTask)
    }
    //new record comes first
    func getRecord(index: Int) -> Record? {
        print(index)
        return DB.loadRecordFromIndex(info.ID, index: count - 1 - index)
    }
    
    func addRecord(record: Record) {
        completedFlagNeedRefresh = true
        recentNeedRefresh = true
        delayHourDir.setDefault(record.taskType)
        DB.addRecord(record)
    }
    
    func delRecord(record: Record) {
        completedFlagNeedRefresh = true
        recentNeedRefresh = true
        DB.delRecord(record.ID)
    }
    
    func taskDelayToTime(toTime: NSDate, task: String) {
        completedFlagNeedRefresh = true
        if let timeCycle = inspectionTaskDir.getTimeCycleForEquipment(info.type, taskName: task){
            
            if let recentInspectionTime = recentRecoredsDir[task] {
                let timeInterval = toTime.timeIntervalSinceDate(recentInspectionTime) as Double
                let delayHour = Int(timeInterval) / 3600
                delayHourDir.editDelayHour(delayHour , task: task)
                print(delayHour )
            } else {
                if let delayHour = delayHourDir[task] {
                    let delaySeconds = Double(delayHour) * 3600.0
                let record = Record(equipmentID: self.info.ID, task: task, recordData: "推迟巡检记录", recordDate: NSDate(timeInterval: -timeCycle * 86400 - delaySeconds, sinceDate: toTime))
                addRecord(record)
                }
            }
        }
    }
    
    func getExpectInspectionTime(task: String) -> NSDate?{
        if let recentInspectionTime = recentRecoredsDir[task] {
            if let delayHour = delayHourDir[task] {
                return NSDate(timeInterval: Double(delayHour) * 3600 , sinceDate: recentInspectionTime)
            }
        }
        return nil
    }
}
class RecordDB {
    private var db: Connection
    private var recordTable: Table
    
    private let equipmentIDExpression = Expression<Int>(ExpressionTitle.EQID.description)
    private let recordIDExpression = Expression<Int>(ExpressionTitle.RecordID.description)
    private let recordMessageExpression = Expression<String?>(ExpressionTitle.RecordMessage.description)
    private let inspectionTaskNameExpression = Expression<String>(ExpressionTitle.InspectionTaskName.description)
    private let recordDateExpression = Expression<NSDate>(ExpressionTitle.RecordDate.description)
    
    func countForEQ(equipmentID: Int) -> Int {
        return self.db.scalar(recordTable.filter(self.equipmentIDExpression == equipmentID).count)
    }
    
    init() {
        self.db = DBModel.sharedInstance().getDB()
        self.recordTable = Table("recordTable")
        
        try! db.run(recordTable.create(ifNotExists: true) { t in
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
            try db.run(insert)
        } catch let error as NSError {
            print(error)
        }
    }
    
    func delRecord(recordID: Int) {
        let alice = recordTable.filter(self.recordIDExpression == recordID)
        do {
            try db.run(alice.delete())
        } catch let error as NSError {
            print(error)
        }
    }
    //MARK: - low efficiency when records became more.
    func loadRecordFromIndex(equipmentID: Int, index: Int) -> Record? {
        let alice = recordTable.filter(self.equipmentIDExpression == equipmentID).limit(1, offset: index)
        if let row = db.pluck(alice) {
            return Record(recordID: row[self.recordIDExpression], equipmentID: row[self.equipmentIDExpression], date: row[recordDateExpression], task: row[inspectionTaskNameExpression], recordData: row[recordMessageExpression])
        } else { return nil }
    }
    func loadRecordFromRecordID(recordID: Int) -> Record {
        let alice = recordTable.filter(self.recordIDExpression == recordID)
        let row = Array(try! db.prepare(alice)).first!
        let record = Record(recordID: row[self.recordIDExpression], equipmentID: row[self.equipmentIDExpression], date: row[recordDateExpression], task: row[inspectionTaskNameExpression], recordData: row[recordMessageExpression])
        return record
        
    }
    
    func loadRecentTimeForType(equipmentID: Int, inspectionTask: String) -> Record? {
        let alice = recordTable.filter(self.equipmentIDExpression == equipmentID && self.inspectionTaskNameExpression == inspectionTask)
        if let lastRecordID = db.scalar(alice.select(recordIDExpression.max)) {
            let record = loadRecordFromRecordID(lastRecordID)
            return record
        } else {
            return nil
        }
    }
}
