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
    var dir: [String: [(String, Double)]] = [: ]

    mutating func addInspectionType(type: InspectionType) {
        dir[type.equipmentType]?.append((typeName: type.inspectionTypeName, timeCycle: type.inspectionCycle))
    }
    
    var equipmentTypeArray: [String] {
        get {
            return Array(dir.keys)
        }
    }
    subscript(index: Int) -> [InspectionType] {
        get {
            let equipmentType = equipmentTypeArray[index]
            if let types =  dir[equipmentType] {
                return types.map({InspectionType(equipmentType: equipmentType, inspectionTypeName: $0.0, inspectionCycle: $0.1)})
            } else {
                return []
            }
        }
    }
}

extension DBModel {
    
    static var defaultInspectionTypeArray: [InspectionType] = [
        InspectionType(equipmentType: "机房精密空调",inspectionTypeName: "日巡视", inspectionCycle: 1),
        InspectionType(equipmentType: "机房精密空调",inspectionTypeName: "周测试", inspectionCycle: 7),
        InspectionType(equipmentType: "机房精密空调",inspectionTypeName: "滤网更换", inspectionCycle: 90),
        InspectionType(equipmentType: "机房精密空调",inspectionTypeName: "室外机清洁", inspectionCycle: 90),
        InspectionType(equipmentType: "机房精密空调",inspectionTypeName: "皮带更换", inspectionCycle: 180),
        InspectionType(equipmentType: "机房精密空调",inspectionTypeName: "加湿罐更换", inspectionCycle: 90),
        InspectionType(equipmentType: "机房精密空调",inspectionTypeName: "季度测试", inspectionCycle: 90),
        InspectionType(equipmentType: "蓄电池组",inspectionTypeName: "周巡视", inspectionCycle: 7)
    ]

    func loadInspectionTypeArray() -> InspectionTypeDir {
        let rows = Array(try! DB.prepare(inspectionTypeTable))
        var inspectionTypeDir = InspectionTypeDir()
        for row in rows {
            let inspectionType = InspectionType(
                equipmentType: row[equipmentType],
                inspectionTypeName: row[inspectionTypeName],
                inspectionCycle: row[inspectionCycle])
            inspectionTypeDir.addInspectionType(inspectionType)
            
        }
        return inspectionTypeDir
    }
    
    func addInspectionType(type: InspectionType) -> Bool {
        let insert = inspectionTypeTable.insert(
            self.inspectionTypeName <- type.inspectionTypeName,
            self.equipmentType <- type.equipmentType,
            self.inspectionCycle <- type.inspectionCycle
        )
        do {
            try DB.run(insert)
            return true
        } catch let error as NSError {
            print(error)
            return false
        }
    }
    
    func changeInspectionTypeCycle(inspectionTypeID: Int, newValue: String) {
        let alice = inspectionTypeTable.filter(self.inspectionTypeID == inspectionTypeID)
        do {
            try DB.run(alice.update(Expression<String>(inspectionCycle) <- newValue))
        } catch let error as NSError {
            print(error)
        }
    }
    
    func delInspectionType(inspectionTypeID: Int) {
        let roomTableAlice = inspectionTypeTable.filter(self.inspectionTypeID == inspectionTypeID)
        do {
            try DB.run(roomTableAlice.delete())
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