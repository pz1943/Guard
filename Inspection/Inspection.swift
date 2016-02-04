//
//  Inspection.swift
//  Inspection
//
//  Created by mac-pz on 16/2/4.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import Foundation

struct Inspection {
    
    struct InspectionType {
        var name: String
        var timeCycle: Double
    }
    static var InspectionTypeArray: [InspectionType] = [InspectionType(name: "日巡视", timeCycle: 1),
        InspectionType(name: "周测试", timeCycle: 7),
        InspectionType(name: "滤网更换", timeCycle: 90),
        InspectionType(name: "室外机清洁", timeCycle: 90),
        InspectionType(name: "皮带更换", timeCycle: 180),
        InspectionType(name: "加湿罐更换", timeCycle: 90),
        InspectionType(name: "季度测试", timeCycle: 90)]
    
    
    static func getTimeCycleDir() -> [String: Double] {
        var timeCycle:[String: Double] = [: ]
        let _ = InspectionTypeArray.map({
            timeCycle[$0.name] = $0.timeCycle
        })
        return timeCycle
    }
    
    static func getTimeCycleArray() -> [(String, Double)] {
        var timeCycle:[(String, Double)] = [ ]
        let _ = InspectionTypeArray.map({
            timeCycle.append(($0.name, $0.timeCycle))
        })
        return timeCycle
    }

    static func getType() -> [String] {
        return InspectionTypeArray.map({$0.name})
    }
    
    static let typeCount = InspectionTypeArray.count
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