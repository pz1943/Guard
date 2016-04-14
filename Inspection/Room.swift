//
//  Room.swift
//  Inspection
//
//  Created by apple on 16/3/14.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import Foundation
import SQLite

class Room {

    var name: String
    var ID: Int
    lazy var equipmentsArray: [Equipment] = {
       return EquipmentArray(roomID: self.ID).arr
    }()
    var isInspectionDone: Bool {
        get {
            for equipment in equipmentsArray {
                if equipment.inspectionDoneFlag == false {
                    return false
                }
            }
            return true
        }
    }
    init(roomID: Int, roomName: String) {
        self.name = roomName
        self.ID = roomID
    }
    
}

class RoomDB {
    private var db: Connection
    private var roomTable: Table
    
    private let roomIDExpression = Expression<Int>(ExpressionTitle.RoomID.description)
    private let roomNameExpression = Expression<String>(ExpressionTitle.RoomName.description)
    init() {
        self.db = DBModel.sharedInstance().getDB()
        
        self.roomTable = Table("roomTable")
        
        try! db.run(roomTable.create(ifNotExists: true) { t in
            t.column(roomIDExpression, primaryKey: true)
            t.column(roomNameExpression)
            })
    }
    
    func reload() {
        DBModel.sharedInstance().reload()
        db = DBModel.sharedInstance().getDB()
    }
    
    func loadRoomTable() -> [Room]{
        let rows = Array(try! db.prepare(roomTable))
        var rooms: [Room] = []
        for row in rows {
            rooms.append(Room(roomID: row[roomIDExpression], roomName: row[roomNameExpression]))
        }
        return rooms
    }
    
    func addRoom(roomName: String) {
        let insert = roomTable.insert(self.roomNameExpression <- roomName)
        do {
            try db.run(insert)
        } catch let error as NSError {
            print(error)
        }
    }
    
    func delRoom(roomID: Int) {
        let roomTableAlice = roomTable.filter(self.roomIDExpression == roomID)
        do {
            try db.run(roomTableAlice.delete())
        } catch let error as NSError {
            print(error)
        }
    }
}
