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

    let roomID = Expression<Int>("roomId")
    let equipmentID = Expression<Int>("equipmentId")
    let recordId = Expression<Int>("recordId")
    let roomName = Expression<String>("roomName")
    let equipmentName = Expression<String>("equipmentName")
    
    let recordMessage = Expression<String?>("recordMessage")
    
    let equipmentBrand = Expression<String?>("equipmentBrand")
    let equipmentModel = Expression<String?>("equipmentModel")
    let equipmentCapacity = Expression<String?>("equipmentCapacity")
    let equipmentCommissionTime = Expression<String?>("equipmentCommissionTime")
    let equipmentSN = Expression<String?>("equipmentSN")

    
    
//    let x = count(*)
    
    struct Constants {
        static let defaultRoom = ["信息北机房","传输机房","电源室","信息南机房"]
        static let defaultEquipmentInRoom = [
            ["北1","北2","北3"],
            ["传1","传2","传3"],
            ["电1","电2"],
            ["南1","南2","南3"]]
    }
    
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
            })
        
        try! DB.run(recordTable.create(ifNotExists: true) { t in
            t.column(recordId, primaryKey: true)
            t.column(equipmentID)
            t.column(recordMessage)
            })
        initDefaultData()
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
    
    
    func loadRoomTable() -> [(Int, String)]{
        let rows = Array(try! DB.prepare(roomTable))
        var rooms: [(Int, String)] = [ ]
        for row in rows {
            rooms.append((row[roomID], row[roomName]))
        }
        return rooms
    }
    
    func loadEquipmentTable(roomID: Int) -> [(Int, String)]{
        let rows = Array(try! DB.prepare(equipmentTable.filter(self.roomID == roomID)))
        var equipments: [(Int, String)] = [ ]
        for row in rows {
            equipments.append((row[equipmentID], row[equipmentName]))
        }
        return equipments
    }
    
    func loadEquipment(equipmentID: Int) -> [(String, String?)]{
        var equipmentDetail: [(String, String?)] = [ ]
        let row = Array(try! DB.prepare(equipmentTable.filter(self.equipmentID == equipmentID))).first
        equipmentDetail.append(("equipmentName", row?[equipmentName]))
        equipmentDetail.append(("equipmentBrand", row?[equipmentBrand]))
        equipmentDetail.append(("equipmentCapacity", row?[equipmentCapacity]))
        equipmentDetail.append(("equipmentCommissionTime", row?[equipmentCommissionTime]))
        equipmentDetail.append(("equipmentSN", row?[equipmentSN]))
        return equipmentDetail
    }
    
    func editEquipment(equipmentID: Int,equipmentDetail: [(String, String)]) {
        let alice = equipmentTable.filter(self.equipmentID == equipmentID)
        for (key, value) in equipmentDetail {
            do {
                try DB.run(alice.update(Expression<String>("\(key)") <- value))
            } catch let error as NSError {
                print(error)
            }
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

    func delEquipment(equipmentId: Int) {
        let alice = equipmentTable.filter(self.equipmentID == equipmentID)
        do {
            try DB.run(alice.delete())
        } catch let error as NSError {
            print(error)
        }
    }
    
//    func addInspectionRecord(record: String, equipmentID: Int) {
//        
//    }
//    
}

enum InspectionType {
    case Daily
    case Weekly
    case FilterChanging
    case Cleaning
    case BeltChanging
    case HumidifyingCansChanging
}