//
//  Delay.swift
//  Inspection
//
//  Created by mac-pz on 16/4/5.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import Foundation
import UIKit
import SQLite

class DelayHourDir {
    fileprivate var delayDir: [String: Double] = [: ]
    fileprivate var info: EquipmentInfo
    fileprivate let DB = DelayDB()
    init(info: EquipmentInfo, taskArray: [InspectionTask]) {
        self.info = info
        self.delayDir = DB.loadDelayHourDir(info,taskArray: taskArray)
    }
    
    subscript(key: String) -> Double? {
        get {
            return delayDir[key]
        }
    }
    
    func editDelayHour(_ hours: Double, task: String) {
        DB.editDelayHourForEquipment(self.info.ID, inspectionTask: task, hours: hours)
        delayDir[task] = hours
    }
    
    func setDefault(_ task: String) {
        editDelayHour(Constants.defaultDelayHour, task: task)
    }
}

class DelayDB {
    fileprivate var db: Connection
    fileprivate var DelayTable: Table
    
    fileprivate let delayIDExpression = Expression<Int>("DelayID")
    fileprivate let delayHourExpression = Expression<Double>("DelayHour")
    fileprivate let inspectionTaskNameExpression = Expression<String>(ExpressionTitle.InspectionTaskName.description)
    fileprivate let equipmentIDExpression = Expression<Int>(ExpressionTitle.EQID.description)
    
    init() {
        self.db = DBModel.sharedInstance.getDB()
        self.DelayTable = Table("DelayTable")
        
        try! db.run(DelayTable.create(ifNotExists: true) { t in
            t.column(delayIDExpression, primaryKey: true)
            t.column(equipmentIDExpression)
            t.column(inspectionTaskNameExpression)
            t.column(delayHourExpression)
            })
    }
    
    func editDelayHourForEquipment(_ equipmentID: Int, inspectionTask: String, hours: Double) {
        
        let alice = DelayTable.filter(self.equipmentIDExpression == equipmentID && self.inspectionTaskNameExpression == inspectionTask)
        do {
            _ = try db.run(alice.update(Expression<Double>(delayHourExpression) <- hours))
        } catch let error as NSError {
            print(error)
        }
    }
    
    func addDelayForEquipment(_ equipmentID: Int, inspectionTask: String, hours: Double) {
        let insert = DelayTable.insert(self.inspectionTaskNameExpression <- inspectionTask,
            self.equipmentIDExpression <- equipmentID,
            self.inspectionTaskNameExpression <- inspectionTask,
            self.delayHourExpression <- hours
        )
        do {
            _ = try db.run(insert)
        } catch let error as NSError {
            print(error)
        }
    }
    
    func delDelayForEquipment(_ equipmentID: Int) {
        let alice = DelayTable.filter(self.equipmentIDExpression == equipmentID)
        do {
            _ = try db.run(alice.delete())
        } catch let error as NSError {
            print(error)
        }
    }
    
    func loadDelayHourDir(_ info: EquipmentInfo, taskArray: [InspectionTask]) -> [String: Double] {
        let filter = DelayTable.filter(self.equipmentIDExpression == info.ID)
        let rows = Array(try! db.prepare(filter))
        var delayDir: [String: Double] = [: ]
        if rows.count != 0 {
            for row in rows {
                delayDir[row[inspectionTaskNameExpression]] = row[delayHourExpression]
            }
        } else {
            for task in taskArray {
                addDelayForEquipment(info.ID, inspectionTask: task.inspectionTaskName, hours: Constants.defaultDelayHour)
                delayDir[task.inspectionTaskName] = Constants.defaultDelayHour
            }
        }
        return delayDir
    }
    
}
