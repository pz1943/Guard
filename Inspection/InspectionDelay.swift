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
    private var delayDir: [String: Double] = [: ]
    private var info: EquipmentInfo
    private let DB = DelayDB()
    init(info: EquipmentInfo, taskArray: [InspectionTask]) {
        self.info = info
        self.delayDir = DB.loadDelayHourDir(info,taskArray: taskArray)
    }
    
    struct Constants {
        static let defaultDelayHour: Double = 10
    }
    
    subscript(key: String) -> Double? {
        get {
            return delayDir[key]
        }
    }
    
    func editDelayHour(hours: Double, task: String) {
        DB.editDelayHourForEquipment(self.info.ID, inspectionTask: task, hours: hours)
        delayDir[task] = hours
    }
    
    func setDefault(task: String) {
        editDelayHour(Constants.defaultDelayHour, task: task)
    }
}

class DelayDB {
    private var db: Connection
    private var DelayTable: Table
    
    private let delayIDExpression = Expression<Int>("DelayID")
    private let delayHourExpression = Expression<Double>("DelayHour")
    private let inspectionTaskNameExpression = Expression<String>(ExpressionTitle.InspectionTaskName.description)
    private let equipmentIDExpression = Expression<Int>(ExpressionTitle.EQID.description)
    
    init() {
        self.db = DBModel.sharedInstance().getDB()
        self.DelayTable = Table("DelayTable")
        
        try! db.run(DelayTable.create(ifNotExists: true) { t in
            t.column(delayIDExpression, primaryKey: true)
            t.column(equipmentIDExpression)
            t.column(inspectionTaskNameExpression)
            t.column(delayHourExpression)
            })
    }
    
    func editDelayHourForEquipment(equipmentID: Int, inspectionTask: String, hours: Double) {
        
        let alice = DelayTable.filter(self.equipmentIDExpression == equipmentID && self.inspectionTaskNameExpression == inspectionTask)
        do {
            try db.run(alice.update(Expression<Double>(delayHourExpression) <- hours))
        } catch let error as NSError {
            print(error)
        }
    }
    
    func addDelayForEquipment(equipmentID: Int, inspectionTask: String, hours: Double) {
        let insert = DelayTable.insert(self.inspectionTaskNameExpression <- inspectionTask,
            self.equipmentIDExpression <- equipmentID,
            self.inspectionTaskNameExpression <- inspectionTask,
            self.delayHourExpression <- hours
        )
        do {
            try db.run(insert)
        } catch let error as NSError {
            print(error)
        }
    }
    
    func loadDelayHourDir(info: EquipmentInfo, taskArray: [InspectionTask]) -> [String: Double] {
        let filter = DelayTable.filter(self.equipmentIDExpression == info.ID)
        let rows = Array(try! db.prepare(filter))
        var delayDir: [String: Double] = [: ]
        if rows.count != 0 {
            for row in rows {
                delayDir[row[inspectionTaskNameExpression]] = row[delayHourExpression]
            }
        } else {
            for task in taskArray {
                addDelayForEquipment(info.ID, inspectionTask: task.inspectionTaskName, hours: 8)
                delayDir[task.inspectionTaskName] = 8
            }
        }
        return delayDir
    }
    
}
