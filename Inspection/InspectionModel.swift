//
//  Inspection.swift
//  Inspection
//
//  Created by mac-pz on 16/2/4.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import Foundation
import SQLite

struct InspectionType {
    var equipmentType: String
    var inspectionTypeName: String
    var inspectionCycle: Double
}

struct InspectionTypeDir {
    private var dir: [String: [(String, Double)]] = [: ]

    mutating func addInspectionType(type: InspectionType) {
        if dir[type.equipmentType] != nil {
            dir[type.equipmentType]!.append((typeName: type.inspectionTypeName, timeCycle: type.inspectionCycle))
        } else {
            dir[type.equipmentType] = [(typeName: type.inspectionTypeName, timeCycle: type.inspectionCycle)]
        }
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
    
    func getInspectionTypeArrayForEquipmentType(equipmentType: String?) -> [InspectionType]{
        if equipmentType != nil {
            if let arr = dir[equipmentType!] {
                return arr.map({InspectionType(equipmentType: equipmentType!, inspectionTypeName: $0.0, inspectionCycle: $0.1)})
            }
        }
        return []
    }
    
    subscript(index: Int?) -> [InspectionType] {
        get {
            if index != nil {
                let equipmentType = equipmentTypeArray[index!]
                if let types =  dir[equipmentType] {
                    return types.map({InspectionType(equipmentType: equipmentType, inspectionTypeName: $0.0, inspectionCycle: $0.1)})
                } else {
                    return []
                }
            } else {
                return []
            }
        }
    }
    
    func getTimeCycleForEquipment(equipmentType: String, type: String) -> Double? {
        var typeDirForEQDir :[String: Double] = [: ]
        if let arr = self.dir[equipmentType] {
            let _ = arr.map({typeDirForEQDir[$0.0] = $0.1})
        }
        return typeDirForEQDir[type]
    }
    
//    func getDirForEquipment(equipmentID: Int) -> [String: Double] {
//        
//    }
}

extension DBModel {
    

    func loadInspectionTypeDir() -> InspectionTypeDir {
        let rows = Array(try! user.prepare(inspectionTypeTable))
        var inspectionTypeDir = InspectionTypeDir()
        for row in rows {
            let inspectionType = InspectionType(
                equipmentType: row[equipmentTypeExpression],
                inspectionTypeName: row[inspectionTypeNameExpression],
                inspectionCycle: row[inspectionCycleExpression])
            inspectionTypeDir.addInspectionType(inspectionType)
            
        }
        return inspectionTypeDir
    }
    
    func addInspectionType(type: InspectionType) -> Bool {
        let insert = inspectionTypeTable.insert(
            self.inspectionTypeNameExpression <- type.inspectionTypeName,
            self.equipmentTypeExpression <- type.equipmentType,
            self.inspectionCycleExpression <- type.inspectionCycle
        )
        do {
            try user.run(insert)
            return true
        } catch let error as NSError {
            print(error)
            return false
        }
    }
    
    func changeInspectionTypeCycle(inspectionTypeID: Int, newValue: String) {
        let alice = inspectionTypeTable.filter(self.inspectionTypeIDExpression == inspectionTypeID)
        do {
            try user.run(alice.update(Expression<String>(inspectionCycleExpression) <- newValue))
        } catch let error as NSError {
            print(error)
        }
    }
    
    func delInspectionType(inspectionTypeID: Int) {
        let roomTableAlice = inspectionTypeTable.filter(self.inspectionTypeIDExpression == inspectionTypeID)
        do {
            try user.run(roomTableAlice.delete())
        } catch let error as NSError {
            print(error)
        }
    }

}


struct InspectionRecord {
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