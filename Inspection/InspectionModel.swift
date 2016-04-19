//
//  Inspection.swift
//  Inspection
//
//  Created by mac-pz on 16/2/4.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import Foundation
import SQLite

func ==(lhs: InspectionType, rhs: InspectionType) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
struct InspectionType: Hashable {
    var equipmentType: String
    var typeName: String
    var cycle: Double
    
    
    var hashValue: Int {
        get {
            return self.typeName.hashValue
        }
    }
}

struct InspectionTypeDir {
    private var dir: [String: [(String, Double)]] = [: ]

    mutating func addInspectionType(type: InspectionType) {
        if dir[type.equipmentType] != nil {
            dir[type.equipmentType]!.append((typeName: type.typeName, timeCycle: type.Cycle))
        } else {
            dir[type.equipmentType] = [(typeName: type.typeName, timeCycle: type.Cycle)]
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



