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
    fileprivate var dir: [String: [InspectionTask]] = [: ]
    fileprivate let DB = InspectionTaskDB()
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
    
    func getTaskArray(_ equipmentType: String?) -> [InspectionTask]{
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
    
    func getTimeCycleForEquipment(_ equipmentType: String, taskName: String) -> Double? {
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

class InspectionTaskDB {
    fileprivate var db: Connection
    fileprivate var inspectionTaskTable: Table
    
    fileprivate let inspectionTaskIDExpression = Expression<Int>(ExpressionTitle.InspectionTaskID.description)
    fileprivate let inspectionCycleExpression = Expression<Double>(ExpressionTitle.InspectionCycle.description)
    fileprivate let equipmentIDExpression = Expression<Int>(ExpressionTitle.EQID.description)
    fileprivate let equipmentTypeExpression = Expression<String>(ExpressionTitle.EQType.description)
    fileprivate let inspectionTaskNameExpression = Expression<String>(ExpressionTitle.InspectionTaskName.description)
    
    init() {
        self.db = DBModel.sharedInstance.getDB()
        self.inspectionTaskTable = Table("inspectionTaskTable")
        
        try! db.run(inspectionTaskTable.create(ifNotExists: true) { t in
            t.column(inspectionTaskIDExpression, primaryKey: true)
            t.column(inspectionTaskNameExpression)
            t.column(equipmentTypeExpression)
            t.column(inspectionCycleExpression)
            })
        
        if try! db.scalar(inspectionTaskTable.count) == 0 {
            initTaskDBData()
        }
    }
    
    
    func initTaskDBData() {
        for taskInArray in Constants.InspectionTaskDataArray {
            let task = InspectionTask(equipmentType: taskInArray[1] as! String, inspectionTaskName: taskInArray[0] as! String, inspectionCycle: Double(taskInArray[2] as! Int))
            _ = addInspectionTask(task)
        }
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
                inspectionTaskDir[type.equipmentType]?.append(type)
            }
        }
        return inspectionTaskDir
    }
    
    func addInspectionTask(_ task: InspectionTask) -> Bool {
        let insert = inspectionTaskTable.insert(
            self.inspectionTaskNameExpression <- task.inspectionTaskName,
            self.equipmentTypeExpression <- task.equipmentType,
            self.inspectionCycleExpression <- task.inspectionCycle
        )
        do {
            _ = try db.run(insert)
            return true
        } catch let error as NSError {
            print(error)
            return false
        }
    }
    
}

