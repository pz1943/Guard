//
//  songListDB.swift
//  DBFM
//
//  Created by apple on 15/12/19.
//  Copyright © 2015年 pz1943. All rights reserved.
//

import Foundation
import SQLite

class DBModel {
    
    var user: Connection
    var roomTable: Table
    var equipmentTable: Table
    var recordTable: Table
    var inspectionTypeTable: Table

    let roomIDExpression = Expression<Int>("roomID")
    let roomNameExpression = Expression<String>("roomName")
    
    let equipmentIDExpression = Expression<Int>(Equipment.EquipmentInfoTitle.ID.rawValue)
    let equipmentNameExpression = Expression<String>(Equipment.EquipmentInfoTitle.Name.rawValue)
    let equipmentTypeExpression = Expression<String>(Equipment.EquipmentInfoTitle.EQType.rawValue)
    let equipmentBrandExpression = Expression<String?>(Equipment.EquipmentInfoTitle.Brand.rawValue)
    let equipmentModelExpression = Expression<String?>(Equipment.EquipmentInfoTitle.Model.rawValue)
    let equipmentCapacityExpression = Expression<String?>(Equipment.EquipmentInfoTitle.Capacity.rawValue)
    let equipmentCommissionTimeExpression = Expression<String?>(Equipment.EquipmentInfoTitle.CommissionTime.rawValue)
    let equipmentSNExpression = Expression<String?>(Equipment.EquipmentInfoTitle.SN.rawValue)
    let equipmentImageNameExpression = Expression<String?>(Equipment.EquipmentInfoTitle.ImageName.rawValue)
    
    let recordIDExpression = Expression<Int>("recordID")
    let recordMessageExpression = Expression<String?>("recordMessage")
    let inspectionTypeNameExpression = Expression<String>("inspectionTypeName")
    let recordDateExpression = Expression<NSDate>("recordDate")
    
    let inspectionTypeIDExpression = Expression<Int>("insepectionTypeID")
    let inspectionCycleExpression = Expression<Double>("inspectionCycle")
    
    struct Static {
        static var instance:DBModel? = nil
        static var token:dispatch_once_t = 0
    }
    
    class func sharedInstance() -> DBModel! {
        dispatch_once(&Static.token) {
            Static.instance = self.init()
        }
        return Static.instance!
    }
    
    func reload() {
        let path = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true
            ).first!
        print("new DB at \(path)")
        user = try! Connection("\(path)/db.sqlite3")
    }
    
    required init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true
            ).first!
        print("DB at \(path)")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.locale = NSLocale(localeIdentifier: "zh_CN")
        dateFormatter.timeZone = NSTimeZone.systemTimeZone()
        
        user = try! Connection("\(path)/db.sqlite3")
        self.roomTable = Table("roomTable")
        self.equipmentTable = Table("equipmentTable")
        self.recordTable = Table("recordTable")
        self.inspectionTypeTable = Table("inspectionTypeTable")
        
        try! user.run(roomTable.create(ifNotExists: true) { t in
            t.column(roomIDExpression, primaryKey: true)
            t.column(roomNameExpression)
            })
        
        try! user.run(equipmentTable.create(ifNotExists: true) { t in
            t.column(equipmentIDExpression, primaryKey: true)
            t.column(equipmentNameExpression)
            t.column(equipmentTypeExpression)
            t.column(roomIDExpression)
            t.column(roomNameExpression)
            t.column(equipmentBrandExpression)
            t.column(equipmentModelExpression)
            t.column(equipmentCapacityExpression)
            t.column(equipmentCommissionTimeExpression)
            t.column(equipmentSNExpression)
            t.column(equipmentImageNameExpression)
            })
        
        try! user.run(recordTable.create(ifNotExists: true) { t in
            t.column(recordIDExpression, primaryKey: true)
            t.column(equipmentIDExpression)
            t.column(inspectionTypeNameExpression)
            t.column(recordMessageExpression)
            t.column(recordDateExpression)
            })
        
        try! user.run(inspectionTypeTable.create(ifNotExists: true) { t in
            t.column(inspectionTypeIDExpression, primaryKey: true)
            t.column(inspectionTypeNameExpression)
            t.column(equipmentTypeExpression)
            t.column(inspectionCycleExpression)
            })

        initDefaultData()
   }
    
}
//MARK: RoomAndEquipmentManagement
extension DBModel {
    
    func loadRoomTable() -> [RoomBrief]{
        let rows = Array(try! user.prepare(roomTable))
        var rooms: [RoomBrief] = [ ]
        for row in rows {
            rooms.append(RoomBrief(ID: row[roomIDExpression], name: row[roomNameExpression], completedFlag: isRoomInspectionCompleted(row[roomIDExpression])))
        }
        return rooms
    }
    
    func loadEquipmentTable(roomID: Int) -> [EquipmentBrief]{
        let rows = Array(try! user.prepare(equipmentTable.filter(self.roomIDExpression == roomID)))
        var equipments: [EquipmentBrief] = [ ]
        for row in rows {
            equipments.append(EquipmentBrief(ID: row[equipmentIDExpression], name: row[equipmentNameExpression], completedFlag: isEquipmentInspectionsCompleted(row[equipmentIDExpression])))
        }
        return equipments
    }
    
    func loadEquipmentType(equipmentID: Int) -> String? {
        let row = Array(try! user.prepare(equipmentTable.filter(self.equipmentIDExpression == equipmentID))).first
        return row?[equipmentTypeExpression]
    }

    func loadEquipment(equipmentID: Int) -> Equipment? {
        let row = Array(try! user.prepare(equipmentTable.filter(self.equipmentIDExpression == equipmentID))).first
        if let name =  row?[equipmentNameExpression] {
            let EQType = row?[equipmentTypeExpression]
            let locatedRoomID = row?[roomIDExpression]
            let locatedRoomName = row?[roomNameExpression]
            let brand = row?[equipmentBrandExpression]
            let model = row?[equipmentModelExpression]
            let capacity = row?[equipmentCapacityExpression]
            let commissionTime = row?[equipmentCommissionTimeExpression]
            let SN = row?[equipmentSNExpression]
            let ImageName = row?[equipmentImageNameExpression]
            
            return Equipment(ID: equipmentID, name: name, type: EQType!, roomID: locatedRoomID!, roomName: locatedRoomName!, brand: brand, model: model, capacity: capacity, commissionTime: commissionTime, SN: SN, imageName: ImageName)
            
        } else {
            return nil
        }
    }
    
    func editEquipment(equipment: Equipment) {
        let alice = equipmentTable.filter(self.equipmentIDExpression == equipment.ID)
        for equipmentDetail in equipment.editableDetailArray {
            do {
                try user.run(alice.update(Expression<String>("\(equipmentDetail.title)") <- equipmentDetail.info))
            } catch let error as NSError {
                print(error)
            }
        }
    }
    // to edit one singel Detail
    func editEquipment(equipmentID: Int, equipmentDetailTitleString: String, newValue: String) {
        let alice = equipmentTable.filter(self.equipmentIDExpression == equipmentID)
        do {
            if equipmentDetailTitleString != Equipment.EquipmentInfoTitle.Name.rawValue {
                try user.run(alice.update(Expression<String?>(equipmentDetailTitleString) <- newValue))
            } else {
                try user.run(alice.update(Expression<String>(equipmentDetailTitleString) <- newValue))
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func addRoom(roomName: String) {
        let insert = roomTable.insert(self.roomNameExpression <- roomName)
        do {
            try user.run(insert)
        } catch let error as NSError {
            print(error)
        }
    }
    
    func delRoom(roomID: Int) {
        let roomTableAlice = roomTable.filter(self.roomIDExpression == roomID)
        do {
            try user.run(roomTableAlice.delete())
        } catch let error as NSError {
            print(error)
        }
        
        let equipmentTableAlice = equipmentTable.filter(self.roomIDExpression == roomID)
        do {
            try user.run(equipmentTableAlice.delete())
        } catch let error as NSError {
            print(error)
        }
    }
    
    func addEquipment(equipmentName: String, equipmentType: String, roomID: Int, roomName: String) {
        let insert = equipmentTable.insert(
            self.equipmentNameExpression <- equipmentName,
            self.equipmentTypeExpression <- equipmentType,
            self.roomIDExpression <- roomID,
            self.roomNameExpression <- roomName)
        do {
            try user.run(insert)
        } catch let error as NSError {
            print(error)
        }
    }
    
    func delEquipment(equipmentToDel: Int) {
        let alice = equipmentTable.filter(self.equipmentIDExpression == equipmentToDel)
        do {
            try user.run(alice.delete())
        } catch let error as NSError {
            print(error)
        }
    }
}
//MARK: testDateInit
extension DBModel {
    struct Constants {
        static let defaultRoom = ["信息北机房","传输机房","电源室","信息南机房"]
        static let defaultEquipmentInRoom = [
            ["北1","北2","北3"],
            ["传1","传2","传3"],
            ["电1","电2"],
            ["南1","南2","南3"]]
        static let defaultInspectionTypeArray: [InspectionType] = [
            InspectionType(equipmentType: "机房精密空调",inspectionTypeName: "日巡视", inspectionCycle: 1),
            InspectionType(equipmentType: "机房精密空调",inspectionTypeName: "周测试", inspectionCycle: 7),
            InspectionType(equipmentType: "机房精密空调",inspectionTypeName: "滤网更换", inspectionCycle: 90),
            InspectionType(equipmentType: "机房精密空调",inspectionTypeName: "室外机清洁", inspectionCycle: 90),
            InspectionType(equipmentType: "机房精密空调",inspectionTypeName: "皮带更换", inspectionCycle: 180),
            InspectionType(equipmentType: "机房精密空调",inspectionTypeName: "加湿罐更换", inspectionCycle: 90),
            InspectionType(equipmentType: "机房精密空调",inspectionTypeName: "季度测试", inspectionCycle: 90),
            InspectionType(equipmentType: "蓄电池组",inspectionTypeName: "周巡视", inspectionCycle: 7)]
    }
    

    func initDefaultData() {
        var roomIndex = 0
        if user.scalar(roomTable.count) == 0 {
            for name in Constants.defaultRoom {
                let insert = roomTable.insert(self.roomNameExpression <- name)
                do {
                    try user.run(insert)
                } catch let error as NSError {
                    print(error)
                }
                for var i = 0; i < Constants.defaultEquipmentInRoom[roomIndex].count; i++ {
                    let insert = equipmentTable.insert(
                        self.roomIDExpression <- roomIndex + 1,
                        self.equipmentTypeExpression <- "机房精密空调",
                        self.equipmentNameExpression <- Constants.defaultEquipmentInRoom[roomIndex][i],
                        self.roomNameExpression <- Constants.defaultRoom[roomIndex])
                    do {
                        try user.run(insert)
                    } catch let error as NSError {
                        print("error when init equipments, error = \(error)")
                    }
                }
                roomIndex++
            }
        }
        if user.scalar(inspectionTypeTable.count) == 0 {
            for var i = 0; i < Constants.defaultInspectionTypeArray.count; i++ {
                let type = Constants.defaultInspectionTypeArray[i]
                self.addInspectionType(InspectionType(equipmentType: type.equipmentType, inspectionTypeName: type.inspectionTypeName, inspectionCycle: type.inspectionCycle))
            }
        }
    }
}
//MARK: RecordManagement
extension DBModel {
    func addInspectionRecord(record: InspectionRecord) {
        let insert = recordTable.insert(self.recordMessageExpression <- record.message,
            self.inspectionTypeNameExpression <- record.recordType,
            self.equipmentIDExpression <- record.equipmentID,
            self.recordDateExpression <- record.date)
        do {
            try user.run(insert)
        } catch let error as NSError {
            print(error)
        }
    }
    
    func delInspectionRecord(recordID: Int) {
        let alice = recordTable.filter(self.recordIDExpression == recordID)
        do {
            try user.run(alice.delete())
        } catch let error as NSError {
            print(error)
        }
    }
    
    func loadInstectionRecord(equipmentID: Int) -> [InspectionRecord]{
        let alice = recordTable.filter(self.equipmentIDExpression == equipmentID)
        var array: [Row] = []
        var recordArray: [InspectionRecord] = []
        do {
            let rows = try user.prepare(alice)
            array = Array(rows)
        } catch let error as NSError {
            print(error)
        }
        for row in array {
            let record = InspectionRecord(recordID: row[self.recordIDExpression], equipmentID: row[self.equipmentIDExpression], date: row[recordDateExpression], type: row[inspectionTypeNameExpression], recordData: row[recordMessageExpression])
            recordArray.insert(record, atIndex: 0)
        }
        return recordArray
    }
    func loadInstectionRecordFromRecordID(recordID: Int) -> InspectionRecord {
        let alice = recordTable.filter(self.recordIDExpression == recordID)
        let row = Array(try! user.prepare(alice)).first!
        let record = InspectionRecord(recordID: row[self.recordIDExpression], equipmentID: row[self.equipmentIDExpression], date: row[recordDateExpression], type: row[inspectionTypeNameExpression], recordData: row[recordMessageExpression])
        return record

    }
    func loadRecentInspectionTime(equipmentID: Int) -> [String: NSDate] {
        var inspectionTime: [String: NSDate] = [: ]
        if let EQType = loadEquipmentType(equipmentID) {
            let types = self.loadInspectionTypeDir().getInspectionTypeArrayForEquipmentType(EQType)
                for type in types {
                    let aTime = loadRecentInspectionTimeForType(equipmentID, inspectionType: type.inspectionTypeName)
                    inspectionTime[type.inspectionTypeName] = aTime
            }
        }
        return inspectionTime
    }

    func loadRecentInspectionTimeForType(equipmentID: Int, inspectionType: String) -> NSDate? {
        let alice = recordTable.filter(self.equipmentIDExpression == equipmentID && self.inspectionTypeNameExpression == inspectionType)
        if let lastRecordID = user.scalar(alice.select(recordIDExpression.max)) {
            let record = loadInstectionRecordFromRecordID(lastRecordID)
            return record.date
        } else {
            return nil
        }
    }
    
    func isEquipmentInspectionsCompleted(equipmentID: Int) -> Bool {
        if let equipmentType = loadEquipmentType(equipmentID) {
            let recentInspectionTimeDir = loadRecentInspectionTime(equipmentID)
            let inspectionTypeDir = self.loadInspectionTypeDir().getInspectionTypeArrayForEquipmentType(equipmentType)
            if recentInspectionTimeDir.count < inspectionTypeDir.count {
                return false
            }
            for (type, date) in recentInspectionTimeDir {
                if isEquipmentInspectionCompleted(equipmentType, type: type, date: date) == false {
                    return false
                }
            }
        }
        return true
    }
    
    func isEquipmentInspectionCompleted(equipmentType: String?, type: String, date: NSDate) -> Bool {
        if equipmentType == nil {
            return false
        }
        let timeCycleDir = self.loadInspectionTypeDir()
        if let timeCycle = timeCycleDir.getTimeCycleForEquipment(equipmentType!, type: type){
            if -date.timeIntervalSinceNow.datatypeValue > Double(timeCycle) * 24 * 3600{
                return false
            }
        }
        return true
    }
    func isRoomInspectionCompleted(roomID: Int) -> Bool {
        let equipments = loadEquipmentTable(roomID)
        for equipment in equipments {
            if equipment.isequipmentInspectonCompleted == false {
                print("EQ \(equipment.equipmentName) UNDONE")
                return false
            }
        }
        return true
    }

}


