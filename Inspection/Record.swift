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
    fileprivate var recordID: Int?
    var equipmentID: Int
    var date: Date
    var taskType: String
    var recorder: String
    var message: String?
    //add a new Record
    init(equipmentID: Int, task: String, recorder: String, recordData: String?, recordDate: Date?) {
        self.equipmentID = equipmentID
        self.taskType = task
        self.message = recordData
        self.recorder = recorder
        if recordDate == nil {
            self.date = Date()
        } else {
            self.date = recordDate!
        }
    }
    //load a exist record
    init(recordID: Int, equipmentID: Int, date: Date, task: String, recorder: String, recordData: String?) {
        self.recordID = recordID
        self.equipmentID = equipmentID
        self.date = date
        self.taskType = task
        self.recorder = recorder
        self.message = recordData
    }
}

class RecordsForEquipment {
    fileprivate var info: EquipmentInfo
    fileprivate let inspectionTaskDir: InspectionTaskDir = InspectionTaskDir()
    fileprivate var inspectionTaskArray: [InspectionTask]
    
    fileprivate let DB = RecordDB()
    init(info: EquipmentInfo, taskArray: [InspectionTask]) {
        self.info = info
        self.inspectionTaskArray = taskArray
        self.delayHourDirCache = DelayHourDir(info: self.info, taskArray: self.inspectionTaskArray)
        self.recentRecoredsDir = getRecentRecords()
    }
    
    fileprivate var recentRecoredsDir: [String: Date] = [: ]
    fileprivate var recentNeedRefresh: Bool = true
    var mostRecentRecordsDir: [String: Date] {
        get {
            if recentNeedRefresh == true {
                recentRecoredsDir = getRecentRecords()
                recentNeedRefresh = false
            }
            return recentRecoredsDir
        }
    }
    
    fileprivate var completedFlagNeedRefresh: Bool = true
    fileprivate var completedFlagCache: Bool = false
    var completedFlag: Bool {
        if completedFlagNeedRefresh == true {
            completedFlagCache = isEquipmentCompleted()
            completedFlagNeedRefresh = false
            return completedFlagCache
        } else {
            return completedFlagCache
        }
    }

    fileprivate var delayHourDirCache: DelayHourDir
    fileprivate var delayHourNeedRefreshFlag: Bool = false
    fileprivate var delayHourDir: DelayHourDir {
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
    
    fileprivate func getRecentRecords() -> [String: Date]{
        var recent: [String: Date] = [: ]
        for type in inspectionTaskArray {
            if let record = DB.loadRecentTimeForType(info.ID, inspectionTask: type.inspectionTaskName) {
                recent[type.inspectionTaskName] = record.date
            }
        }
        return recent
    }       
    
    fileprivate func isEquipmentCompleted() -> Bool{
        for task in inspectionTaskArray {
            if CompletedForTask(task) == false {
                return false
            }
        }
        return true
    }
    
    fileprivate func CompletedForTask(_ inspectionTask: InspectionTask) -> Bool {
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
    
    func getTimeCycleForTask(_ task: String) -> Double? {
        return inspectionTaskDir.getTimeCycleForEquipment(info.type, taskName: task)
    }
    
    func getDelayHourForTask(_ task: String) -> Double? {
        return delayHourDir[task]
    }
    
    func isCompletedForTask(_ inspectionTask: InspectionTask) -> Bool {
        return self.CompletedForTask(inspectionTask)
    }
    //new record comes first
    func getRecord(_ index: Int) -> Record? {
//        print(index)
        return DB.loadRecordFromIndex(info.ID, index: count - 1 - index)
    }
    
    func addRecord(_ record: Record) {
        completedFlagNeedRefresh = true
        recentNeedRefresh = true
        delayHourDir.setDefault(record.taskType)
        DB.addRecord(record)
    }
    
    func delRecord(_ record: Record) {
        completedFlagNeedRefresh = true
        recentNeedRefresh = true
        self.delayHourDir.setDefault(record.taskType)
        DB.delRecord(record.ID)
    }
    
    func taskDelayToTime(_ toTime: Date, task: String) {
        completedFlagNeedRefresh = true
        if let timeCycle = inspectionTaskDir.getTimeCycleForEquipment(info.type, taskName: task){
            if let recentInspectionTime = recentRecoredsDir[task] {
                let timeInterval = toTime.timeIntervalSince(recentInspectionTime) as Double - timeCycle * 86400
                let delayHour = timeInterval / 3600
                delayHourDir.editDelayHour(delayHour , task: task)
            } else {
                if let delayHour = delayHourDir[task] {
                    let delaySeconds = Double(delayHour) * 3600.0
                    let record = Record(equipmentID: self.info.ID, task: task, recorder: "system", recordData: "推迟巡检记录", recordDate: Date(timeInterval: -timeCycle * 86400 - delaySeconds, since: toTime))
                    addRecord(record)
                }
            }
        }
    }
    
    func getExpectInspectionTime(_ task: String) -> Date?{
        if let recentInspectionTime = recentRecoredsDir[task] {
            if let delayHour = delayHourDir[task] {
                let timeCycle = inspectionTaskDir.getTimeCycleForEquipment(info.type, taskName: task) ?? 0
                return Date(timeInterval: Double(delayHour) * 3600 + timeCycle * 86400 , since: recentInspectionTime)
            }
        }
        return nil
    }
}
class RecordDB {
    fileprivate var db: Connection
    fileprivate var recordTable: Table
    
    fileprivate let equipmentIDExpression = Expression<Int>(ExpressionTitle.EQID.description)
    fileprivate let recordIDExpression = Expression<Int>(ExpressionTitle.RecordID.description)
    fileprivate let recordMessageExpression = Expression<String?>(ExpressionTitle.RecordMessage.description)
    fileprivate let inspectionTaskNameExpression = Expression<String>(ExpressionTitle.InspectionTaskName.description)
    fileprivate let recorderExpression = Expression<String>(ExpressionTitle.Recorder.description)
    fileprivate let recordDateExpression = Expression<Date>(ExpressionTitle.RecordDate.description)
    
    func countForEQ(_ equipmentID: Int) -> Int {
        return try! self.db.scalar(recordTable.filter(self.equipmentIDExpression == equipmentID).count)
    }
    
    init() {
        self.db = DBModel.sharedInstance.getDB()
        self.recordTable = Table("recordTable")
        
        try! db.run(recordTable.create(ifNotExists: true) { t in
            t.column(recordIDExpression, primaryKey: true)
            t.column(equipmentIDExpression)
            t.column(inspectionTaskNameExpression)
            t.column(recordMessageExpression)
            t.column(recorderExpression)
            t.column(recordDateExpression)
            })
    }
    
    func addRecord(_ record: Record) {
        let insert = recordTable.insert(self.recordMessageExpression <- record.message,
            self.inspectionTaskNameExpression <- record.taskType,
            self.equipmentIDExpression <- record.equipmentID,
            self.recorderExpression <- record.recorder,
            self.recordDateExpression <- record.date)
        do {
            _ = try db.run(insert)
        } catch let error as NSError {
            print(error)
        }
    }
    
    func delRecord(_ recordID: Int) {
        let alice = recordTable.filter(self.recordIDExpression == recordID)
        do {
            _ = try db.run(alice.delete())
        } catch let error as NSError {
            print(error)
        }
    }
    //MARK: - low efficiency when records became more.
    func loadRecordFromIndex(_ equipmentID: Int, index: Int) -> Record? {
        let alice = recordTable.filter(self.equipmentIDExpression == equipmentID).limit(1, offset: index)
        if let row = try! db.pluck(alice) {
            return Record(recordID: row[self.recordIDExpression], equipmentID: row[self.equipmentIDExpression], date: row[recordDateExpression], task: row[inspectionTaskNameExpression], recorder: row[recorderExpression], recordData: row[recordMessageExpression])
        } else { return nil }
    }
    func loadRecordFromRecordID(_ recordID: Int) -> Record {
        let alice = recordTable.filter(self.recordIDExpression == recordID)
        let row = Array(try! db.prepare(alice)).first!
        let record = Record(recordID: row[self.recordIDExpression], equipmentID: row[self.equipmentIDExpression], date: row[recordDateExpression], task: row[inspectionTaskNameExpression], recorder: row[recorderExpression], recordData: row[recordMessageExpression])
        return record
        
    }
    
    func loadRecentTimeForType(_ equipmentID: Int, inspectionTask: String) -> Record? {
        let alice = recordTable.filter(self.equipmentIDExpression == equipmentID && self.inspectionTaskNameExpression == inspectionTask)
        if let lastRecordID = try! db.scalar(alice.select(recordIDExpression.max)) {
            let record = loadRecordFromRecordID(lastRecordID)
            return record
        } else {
            return nil
        }
    }
}
