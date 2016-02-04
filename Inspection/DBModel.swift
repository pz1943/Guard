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
    
    var DB: Connection
    var roomTable: Table
    var equipmentTable: Table
    var recordTable: Table

    let roomID = Expression<Int>("roomID")
    let roomName = Expression<String>("roomName")
    
    let equipmentID = Expression<Int>(Equipment.EquipmentInfoTitle.ID.rawValue)
    let equipmentName = Expression<String>(Equipment.EquipmentInfoTitle.Name.rawValue)
    let equipmentBrand = Expression<String?>(Equipment.EquipmentInfoTitle.Brand.rawValue)
    let equipmentModel = Expression<String?>(Equipment.EquipmentInfoTitle.Model.rawValue)
    let equipmentCapacity = Expression<String?>(Equipment.EquipmentInfoTitle.Capacity.rawValue)
    let equipmentCommissionTime = Expression<String?>(Equipment.EquipmentInfoTitle.CommissionTime.rawValue)
    let equipmentSN = Expression<String?>(Equipment.EquipmentInfoTitle.SN.rawValue)
    let equipmentImageName = Expression<String?>(Equipment.EquipmentInfoTitle.ImageName.rawValue)
    
    let recordID = Expression<Int>("recordID")
    let recordMessage = Expression<String?>("recordMessage")
    let recordType = Expression<String>("recordType")
    let recordDate = Expression<NSDate>("recordDate")
    
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

    required init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true
            ).first!
        print("DB at \(path)")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.locale = NSLocale(localeIdentifier: "zh_CN")
        dateFormatter.timeZone = NSTimeZone.systemTimeZone()

        DB = try! Connection("\(path)/db.sqlite3")
        self.roomTable = Table("roomTable")
        self.equipmentTable = Table("equipmentTable")
        self.recordTable = Table("recordTable")
        
        try! DB.run(roomTable.create(ifNotExists: true) { t in
            t.column(roomID, primaryKey: true)
            t.column(roomName)
            })
        
        try! DB.run(equipmentTable.create(ifNotExists: true) { t in
            t.column(equipmentID, primaryKey: true)
            t.column(equipmentName)
            t.column(roomID)
            t.column(roomName)
            t.column(equipmentBrand)
            t.column(equipmentModel)
            t.column(equipmentCapacity)
            t.column(equipmentCommissionTime)
            t.column(equipmentSN)
            t.column(equipmentImageName)
            })
        
        try! DB.run(recordTable.create(ifNotExists: true) { t in
            t.column(recordID, primaryKey: true)
            t.column(equipmentID)
            t.column(recordType)
            t.column(recordMessage)
            t.column(recordDate)
            })
        initDefaultData()
   }
    
    
    func loadRoomTable() -> [RoomBrief]{
        let rows = Array(try! DB.prepare(roomTable))
        var rooms: [RoomBrief] = [ ]
        for row in rows {
            rooms.append(RoomBrief(ID: row[roomID], name: row[roomName], completedFlag: isRoomInspectionCompleted(row[roomID])))
        }
        return rooms
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
    
    func loadEquipmentTable(roomID: Int) -> [EquipmentBrief]{
        let rows = Array(try! DB.prepare(equipmentTable.filter(self.roomID == roomID)))
        var equipments: [EquipmentBrief] = [ ]
        for row in rows {
            equipments.append(EquipmentBrief(ID: row[equipmentID], name: row[equipmentName], completedFlag: isEquipmentInspectionCompleted(row[equipmentID])))
        }
        return equipments
    }
    
    func isEquipmentInspectionCompleted(equipmentID: Int) -> Bool {
        let inspectionTimeDir = loadRecentInspectionTime(equipmentID)
        if inspectionTimeDir.count < Inspection.typeCount {
            return false
        }
        let timeCycleDir = Inspection.getTimeCycleDir()
        for (type, date) in inspectionTimeDir {
            if let timeCycle = timeCycleDir[type]{
                if -date.timeIntervalSinceNow.datatypeValue > Double(timeCycle) * 24 * 3600{
                    return false
                }
            }
        }
        return true
    }
    //MARK: TODO- 完善设备详情页面条目的特殊颜色显示。
    func loadEquipmentInspectionState() {
        
    }
    
    func loadEquipment(equipmentID: Int) -> Equipment? {
        let row = Array(try! DB.prepare(equipmentTable.filter(self.equipmentID == equipmentID))).first
        if let name =  row?[equipmentName] {
            let locatedRoomID = row?[roomID]
            let locatedRoomName = row?[roomName]
            let brand = row?[equipmentBrand]
            let model = row?[equipmentModel]
            let capacity = row?[equipmentCapacity]
            let commissionTime = row?[equipmentCommissionTime]
            let SN = row?[equipmentSN]
            let ImageName = row?[equipmentImageName]
            
            return Equipment(ID: equipmentID, name: name, roomID: locatedRoomID!, roomName: locatedRoomName!, brand: brand, model: model, capacity: capacity, commissionTime: commissionTime, SN: SN, imageName: ImageName)

        } else {
            return nil
        }
    }

    func editEquipment(equipment: Equipment) {
        let alice = equipmentTable.filter(self.equipmentID == equipment.ID)
        for equipmentDetail in equipment.editableDetailArray {
            do {
                try DB.run(alice.update(Expression<String>("\(equipmentDetail.title)") <- equipmentDetail.info))
            } catch let error as NSError {
                print(error)
            }
        }
    }
// to edit one singel Detail
    func editEquipment(equipmentID: Int, equipmentDetailTitleString: String, newValue: String) {
        let alice = equipmentTable.filter(self.equipmentID == equipmentID)
        do {
            if equipmentDetailTitleString != Equipment.EquipmentInfoTitle.Name.rawValue {
                try DB.run(alice.update(Expression<String?>(equipmentDetailTitleString) <- newValue))
            } else {
                try DB.run(alice.update(Expression<String>(equipmentDetailTitleString) <- newValue))
            }
        } catch let error as NSError {
            print(error)
        }
    }
 
    func addRoom(roomName: String) {
        let insert = roomTable.insert(self.roomName <- roomName)
        do {
            try DB.run(insert)
        } catch let error as NSError {
            print(error)
        }
    }

    func delRoom(roomID: Int) {
        let roomTableAlice = roomTable.filter(self.roomID == roomID)
        do {
            try DB.run(roomTableAlice.delete())
        } catch let error as NSError {
            print(error)
        }
        
        let equipmentTableAlice = equipmentTable.filter(self.roomID == roomID)
        do {
            try DB.run(equipmentTableAlice.delete())
        } catch let error as NSError {
            print(error)
        }
    }
    
    func addEquipment(equipmentName: String, roomID: Int, roomName: String) {
        let insert = equipmentTable.insert(
            self.equipmentName <- equipmentName,
            self.roomID <- roomID,
            self.roomName <- roomName)
        do {
            try DB.run(insert)
        } catch let error as NSError {
            print(error)
        }
    }

    func delEquipment(equipmentToDel: Int) {
        let alice = equipmentTable.filter(self.equipmentID == equipmentToDel)
        do {
            try DB.run(alice.delete())
        } catch let error as NSError {
            print(error)
        }
    }
    
    
}
// 初始化数据，测试用
extension DBModel {
    struct Constants {
        static let defaultRoom = ["信息北机房","传输机房","电源室","信息南机房"]
        static let defaultEquipmentInRoom = [
            ["北1","北2","北3"],
            ["传1","传2","传3"],
            ["电1","电2"],
            ["南1","南2","南3"]]
    }
    
    func initDefaultData() {
        var result = try! DB.prepare(roomTable.count)
        for row: Row in result {
            let countExpression = count(*)
            if row.get(countExpression) == 0 {
                for name in Constants.defaultRoom {
                    let insert = roomTable.insert(self.roomName <- name)
                    do {
                        try DB.run(insert)
                    } catch let error as NSError {
                        print(error)
                    }
                }
            }
        }
        result = try! DB.prepare(equipmentTable.count)
        for row: Row in result {
            for var roomIndex = 0; roomIndex < Constants.defaultRoom.count; roomIndex++ {
                let countExpression = count(*)
                if row.get(countExpression) == 0 {
                    for var i = 0; i < Constants.defaultEquipmentInRoom[roomIndex].count; i++ {
                        let insert = equipmentTable.insert(
                            self.roomID <- roomIndex + 1,
                            self.equipmentName <- Constants.defaultEquipmentInRoom[roomIndex][i],
                            self.roomName <- Constants.defaultRoom[roomIndex])
                        do {
                            try DB.run(insert)
                        } catch let error as NSError {
                            print(error)
                        }
                    }
                }
            }
        }
    }
}
// 管理巡检数据
extension DBModel {
    func addInspectionRecord(record: InspectionRecord) {
        let insert = recordTable.insert(self.recordMessage <- record.message,
            self.recordType <- record.recordType,
            self.equipmentID <- record.equipmentID,
            self.recordDate <- record.date)
        do {
            try DB.run(insert)
        } catch let error as NSError {
            print(error)
        }
    }
    
    func delInspectionRecord(recordID: Int) {
        let alice = recordTable.filter(self.recordID == recordID)
        do {
            try DB.run(alice.delete())
        } catch let error as NSError {
            print(error)
        }
    }
    
    func loadInstectionRecord(equipmentID: Int) -> [InspectionRecord]{
        let alice = recordTable.filter(self.equipmentID == equipmentID)
        var array: [Row] = []
        var recordArray: [InspectionRecord] = []
        do {
            let rows = try DB.prepare(alice)
            array = Array(rows)
        } catch let error as NSError {
            print(error)
        }
        for row in array {
            let record = InspectionRecord(recordID: row[self.recordID], equipmentID: row[self.equipmentID], date: row[recordDate], type: row[recordType], recordData: row[recordMessage])
            recordArray.append(record)
        }
        return recordArray
    }
    
    func loadRecentInspectionTime(equipmentID: Int) -> [String: NSDate] {
        var inspectionTime: [String: NSDate] = [: ]
        for type in Inspection.getType() {
            let aTime = loadRecentInspectionTimeForType(equipmentID, inspectionType: type)
            inspectionTime[type] = aTime
        }
        return inspectionTime
    }
    //MARK: TODO 得到的不是最新的数据，需要修改
    func loadRecentInspectionTimeForType(equipmentID: Int, inspectionType: String) -> NSDate? {
        let alice = recordTable.filter(self.equipmentID == equipmentID && self.recordType == inspectionType)
        let row = DB.pluck(alice)
        return row?[recordDate]
    }
}
