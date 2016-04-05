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
    var delayDir: [String: Int] = [: ]
    init(equipment: Equipment) {
        let DB = DelayDB()
        self.delayDir = DB.loadDelayHourDir(equipment)
    }
    
    subscript(key: String) -> Int? {
        get {
            return delayDir[key]
        }
    }
}

class DelayDB {
    private var db: Connection
    private var DelayTable: Table
    
    private let delayIDExpression = Expression<Int>("DelayID")
    private let delayHourExpression = Expression<Int>("DelayHour")
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
    
    func editDelayHourForEquipment(equipmentID: Int, inspectionTask: String, hours: Int) {
        let alice = DelayTable.filter(self.equipmentIDExpression == equipmentID && self.inspectionTaskNameExpression == inspectionTask)
        do {
            try db.run(alice.update(Expression<Int>(delayHourExpression) <- hours))
        } catch let error as NSError {
            print(error)
        }
    }
    
    func addDelayForEquipment(equipmentID: Int, inspectionTask: String, hours: Int) {
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
    
    func loadDelayHourDir(equipment: Equipment) -> [String: Int] {
        let filter = DelayTable.filter(self.equipmentIDExpression == equipment.ID)
        let rows = Array(try! db.prepare(filter))
        var delayDir: [String: Int] = [: ]
        if rows.count != 0 {
            for row in rows {
                delayDir[row[inspectionTaskNameExpression]] = row[delayHourExpression]
            }
        } else {
            for task in equipment.inspectionTaskDir {
                addDelayForEquipment(equipment.ID, inspectionTask: task.inspectionTaskName, hours: 8)
                delayDir[task.inspectionTaskName] = 8
            }
        }
        return delayDir
    }
    
}
