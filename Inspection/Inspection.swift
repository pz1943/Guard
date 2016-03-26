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
    private let DB = InspectionTaskDB()
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
    
    func getTimeCycleForEquipment(equipmentType: String, taskName: String) -> Double? {
        var cycle: Double = 0.0
        
        if let typeArray = dir[equipmentType] {
            for task in typeArray {
                if task.inspectionTaskName == taskName {
                    cycle = task.inspectionCycle
                }
            }
            return cycle
        } else {
            return nil
        }
    }
}

//struct InspectionDelayDir {
//    private var dir: [String: Int] = [: ]
//    private let DB = InspectionDelayDB()
//    init(equipmentID: Int) {
//        self.dir = DB.loadInspectionDelayDir(equipmentID)
//    }
//    
//}

class InspectionDelayDB {
    private var db: Connection
    private var inspectionDelayTable: Table
    
    private let inspectionDelayIDExpression = Expression<Int>("inspectionDelayID")
    private let inspectionDelayHourExpression = Expression<Int>("inspectionDelayHour")
    private let inspectionTaskNameExpression = Expression<String>(ExpressionTitle.InspectionTaskName.description)
    private let equipmentIDExpression = Expression<Int>(ExpressionTitle.EQID.description)
    
    init() {
        self.db = DBModel.sharedInstance().getDB()
        self.inspectionDelayTable = Table("inspectionDelayTable")
        
        try! db.run(inspectionDelayTable.create(ifNotExists: true) { t in
            t.column(inspectionDelayIDExpression, primaryKey: true)
            t.column(equipmentIDExpression)
            t.column(inspectionTaskNameExpression)
            t.column(inspectionDelayHourExpression)
            })
    }
    
    func editInspectionDelayHourForEquipment(equipmentID: Int, inspectionTask: String, hours: Int) {
        let alice = inspectionDelayTable.filter(self.equipmentIDExpression == equipmentID && self.inspectionTaskNameExpression == inspectionTask)
        do {
            try db.run(alice.update(Expression<Int>(inspectionDelayHourExpression) <- hours))
        } catch let error as NSError {
            print(error)
        }
    }
    
    func addInspectionDelayForEquipment(equipmentID: Int, inspectionTask: String, hours: Int) {
        let insert = inspectionDelayTable.insert(self.inspectionTaskNameExpression <- inspectionTask,
            self.equipmentIDExpression <- equipmentID,
            self.inspectionTaskNameExpression <- inspectionTask,
            self.inspectionDelayHourExpression <- hours
        )
        do {
            try db.run(insert)
        } catch let error as NSError {
            print(error)
        }
    }
    
}
class InspectionTaskDB {
    private var db: Connection
    private var inspectionTaskTable: Table
    
    private let inspectionTaskIDExpression = Expression<Int>(ExpressionTitle.InspectionTaskID.description)
    private let inspectionCycleExpression = Expression<Double>(ExpressionTitle.InspectionCycle.description)
    private let equipmentIDExpression = Expression<Int>(ExpressionTitle.EQID.description)
    private let equipmentTypeExpression = Expression<String>(ExpressionTitle.EQType.description)
    private let inspectionTaskNameExpression = Expression<String>(ExpressionTitle.InspectionTaskName.description)
    
    init() {
        self.db = DBModel.sharedInstance().getDB()
        self.inspectionTaskTable = Table("inspectionTaskTable")
        
        try! db.run(inspectionTaskTable.create(ifNotExists: true) { t in
            t.column(inspectionTaskIDExpression, primaryKey: true)
            t.column(inspectionTaskNameExpression)
            t.column(equipmentTypeExpression)
            t.column(inspectionCycleExpression)
            })
    }
    
    func loadInspectionTaskDir() -> [String: [InspectionTask]] {
        let rows = Array(try! db.prepare(inspectionTaskTable))
        var inspectionTaskDir: [String: [InspectionTask]] = [: ]
        for row in rows {
            let type = InspectionTask(
                equipmentType: row[equipmentTypeExpression],
                inspectionTaskName: row[inspectionTaskNameExpression],
                inspectionCycle: row[inspectionCycleExpression])
            if inspectionTaskDir[type.equipmentType] != nil {
                inspectionTaskDir[type.equipmentType]?.append(type)
            } else {
                inspectionTaskDir[type.equipmentType] = [type]
            }
        }
        return inspectionTaskDir
    }
    
    func addInspectionTask(type: InspectionTask) -> Bool {
        let insert = inspectionTaskTable.insert(
            self.inspectionTaskNameExpression <- type.inspectionTaskName,
            self.equipmentTypeExpression <- type.equipmentType,
            self.inspectionCycleExpression <- type.inspectionCycle
        )
        do {
            try db.run(insert)
            return true
        } catch let error as NSError {
            print(error)
            return false
        }
    }
    
}

