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
    private var user: Connection
    private var roomTable: Table
    private var equipmentTable: Table
    private var recordTable: Table
    private var inspectionTypeTable: Table
    private var inspectionDelayTable: Table
    
    private let roomIDExpression = Expression<Int>("roomID")
    private let roomNameExpression = Expression<String>("roomName")
    
    private let equipmentIDExpression = Expression<Int>(Equipment.EquipmentInfoTitle.ID.rawValue)
    private let equipmentNameExpression = Expression<String>(Equipment.EquipmentInfoTitle.Name.rawValue)
    private let equipmentTypeExpression = Expression<String>(Equipment.EquipmentInfoTitle.EQType.rawValue)
    private let equipmentBrandExpression = Expression<String?>(Equipment.EquipmentInfoTitle.Brand.rawValue)
    private let equipmentModelExpression = Expression<String?>(Equipment.EquipmentInfoTitle.Model.rawValue)
    private let equipmentCapacityExpression = Expression<String?>(Equipment.EquipmentInfoTitle.Capacity.rawValue)
    private let equipmentCommissionTimeExpression = Expression<String?>(Equipment.EquipmentInfoTitle.CommissionTime.rawValue)
    private let equipmentSNExpression = Expression<String?>(Equipment.EquipmentInfoTitle.SN.rawValue)
    private let equipmentImageNameExpression = Expression<String?>(Equipment.EquipmentInfoTitle.ImageName.rawValue)
    
    private let recordIDExpression = Expression<Int>("recordID")
    private let recordMessageExpression = Expression<String?>("recordMessage")
    private let inspectionTypeNameExpression = Expression<String>("inspectionTypeName")
    private let recordDateExpression = Expression<NSDate>("recordDate")
    
    private let inspectionTypeIDExpression = Expression<Int>("insepectionTypeID")
    private let inspectionCycleExpression = Expression<Double>("inspectionCycle")
    
    private let inspectionDelayIDExpression = Expression<Int>("inspectionDelayID")
    private let inspectionDelayHourExpression = Expression<Int>("inspectionDelayHour")
    
    
    private var inspectionDelayHoursDir: [Int: Int] = [: ]
    
    struct Static {
        static var instance:DBModel? = nil
        static var token:dispatch_once_t = 0
    }
    
    struct Constants {
        static let inspectionDelayHour: Int = 8
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
        self.inspectionDelayTable = Table("inspectionDelayTable")
        
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
        
        try! user.run(inspectionDelayTable.create(ifNotExists: true) { t in
            t.column(inspectionDelayIDExpression, primaryKey: true)
            t.column(equipmentIDExpression)
            t.column(inspectionTypeNameExpression)
            t.column(inspectionDelayHourExpression)
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
            equipments.append(EquipmentBrief(ID: row[equipmentIDExpression], name: row[equipmentNameExpression], completedFlag: isEquipmentCompleted(row[equipmentIDExpression])))
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
    struct defaultData {
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
            for name in defaultData.defaultRoom {
                let insert = roomTable.insert(self.roomNameExpression <- name)
                do {
                    try user.run(insert)
                } catch let error as NSError {
                    print(error)
                }
                for var i = 0; i < defaultData.defaultEquipmentInRoom[roomIndex].count; i++ {
                    let insert = equipmentTable.insert(
                        self.roomIDExpression <- roomIndex + 1,
                        self.equipmentTypeExpression <- "机房精密空调",
                        self.equipmentNameExpression <- defaultData.defaultEquipmentInRoom[roomIndex][i],
                        self.roomNameExpression <- defaultData.defaultRoom[roomIndex])
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
            for var i = 0; i < defaultData.defaultInspectionTypeArray.count; i++ {
                let type = defaultData.defaultInspectionTypeArray[i]
                self.addInspectionType(InspectionType(equipmentType: type.equipmentType, inspectionTypeName: type.inspectionTypeName, inspectionCycle: type.inspectionCycle))
            }
        }
        
        if user.scalar(inspectionDelayTable.count) == 0 {
            let rooms = self.loadRoomTable()
            for room in rooms {
                let equipments = self.loadEquipmentTable(room.roomID)
                for equipment in equipments {
                    let EQtype = self.loadEquipmentType(equipment.equipmentID)
                    for type in self.loadInspectionTypeDir().getInspectionTypeArrayForEquipmentType(EQtype){
                        self.addInspectionDelayForEquipment(equipment.equipmentID, inspectionType: type.inspectionTypeName, hours: Constants.inspectionDelayHour)
                    }

                }
            }
        } else {
            let rows = Array(try! user.prepare(inspectionDelayTable))
            for row in rows {
                inspectionDelayHoursDir[row[inspectionDelayIDExpression]] = row[inspectionDelayHourExpression]
            }
        }

        
    }
}
//MARK: RecordManagement
extension DBModel {
    func addRecord(record: Record) {
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
    
    func delRecord(recordID: Int) {
        let alice = recordTable.filter(self.recordIDExpression == recordID)
        do {
            try user.run(alice.delete())
        } catch let error as NSError {
            print(error)
        }
    }
    //MARK: - low efficiency when records became more.
    func loadRecordFromEquipmetID(equipmentID: Int) -> [Record]{
        let alice = recordTable.filter(self.equipmentIDExpression == equipmentID)
        var array: [Row] = []
        var recordArray: [Record] = []
        do {
            let rows = try user.prepare(alice)
            array = Array(rows)
        } catch let error as NSError {
            print(error)
        }
        for row in array {
            let record = Record(recordID: row[self.recordIDExpression], equipmentID: row[self.equipmentIDExpression], date: row[recordDateExpression], type: row[inspectionTypeNameExpression], recordData: row[recordMessageExpression])
            recordArray.insert(record, atIndex: 0)
        }
        return recordArray
    }
    func loadRecordFromRecordID(recordID: Int) -> Record {
        let alice = recordTable.filter(self.recordIDExpression == recordID)
        let row = Array(try! user.prepare(alice)).first!
        let record = Record(recordID: row[self.recordIDExpression], equipmentID: row[self.equipmentIDExpression], date: row[recordDateExpression], type: row[inspectionTypeNameExpression], recordData: row[recordMessageExpression])
        return record

    }

    func loadRecentTimeForType(equipmentID: Int, inspectionType: String) -> Record? {
        let alice = recordTable.filter(self.equipmentIDExpression == equipmentID && self.inspectionTypeNameExpression == inspectionType)
        if let lastRecordID = user.scalar(alice.select(recordIDExpression.max)) {
            let record = loadRecordFromRecordID(lastRecordID)
            return record
        } else {
            return nil
        }
    }
//
//    func isEquipmentCompleted(equipmentID: Int) -> Bool {
//        if let equipmentType = loadEquipmentType(equipmentID) {
//            let recentInspectionTimeDir = loadRecentTimeDir(equipmentID)
//            let inspectionTypeDir = self.loadInspectionTypeDir().getInspectionTypeArrayForEquipmentType(equipmentType)
//            if recentInspectionTimeDir.count < inspectionTypeDir.count {
//                return false
//            }
//            for (type, date) in recentInspectionTimeDir {
//                if isEquipmentCompleted(equipmentType, type: type, date: date) == false {
//                    return false
//                }
//            }
//        }
//        return true
//    }
//    
//    func isEquipmentCompleted(equipmentType: String?, type: String, date: NSDate) -> Bool {
//        if equipmentType == nil {
//            return false
//        }
//        let timeCycleDir = self.loadInspectionTypeDir()
//        if let timeCycle = timeCycleDir.getTimeCycleForEquipment(equipmentType!, type: type){
//            if -date.timeIntervalSinceNow.datatypeValue > Double(timeCycle) * 24 * 3600{
//                return false
//            }
//        }
//        return true
//    }
//    func isRoomCompleted(roomID: Int) -> Bool {
//        let equipments = loadEquipmentTable(roomID)
//        for equipment in equipments {
//            if equipment.isequipmentInspectonCompleted == false {
//                print("EQ \(equipment.equipmentName) UNDONE")
//                return false
//            }
//        }
//        return true
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
//
//    func changeInspectionTypeCycle(inspectionTypeID: Int, newValue: String) {
//        let alice = inspectionTypeTable.filter(self.inspectionTypeIDExpression == inspectionTypeID)
//        do {
//            try user.run(alice.update(Expression<String>(inspectionCycleExpression) <- newValue))
//        } catch let error as NSError {
//            print(error)
//        }
//    }
//    
//    func delInspectionType(inspectionTypeID: Int) {
//        let roomTableAlice = inspectionTypeTable.filter(self.inspectionTypeIDExpression == inspectionTypeID)
//        do {
//            try user.run(roomTableAlice.delete())
//        } catch let error as NSError {
//            print(error)
//        }
//    }
    
}

extension DBModel {
    func editInspectionDelayHourForEquipment(equipmentID: Int, inspectionType: String, hours: Int) {
        
    }
    
    func addInspectionDelayForEquipment(equipmentID: Int, inspectionType: String, hours: Int) {
        let insert = inspectionDelayTable.insert(self.inspectionTypeNameExpression <- inspectionType,
            self.equipmentIDExpression <- equipmentID,
            self.inspectionDelayHourExpression <- hours
        )
        do {
            try user.run(insert)
        } catch let error as NSError {
            print(error)
        }
    }
}


