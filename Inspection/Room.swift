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
    var equipmentsArray: [Equipment]
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
    init(roomID: Int, roomName: String, equipments: [Equipment]){
        self.name = roomName
        self.ID = roomID
        self.equipmentsArray = equipments
    }
    init(roomID: Int, roomName: String) {
        self.name = roomName
        self.ID = roomID
        self.equipmentsArray = EquipmentDB().loadEquipmentTable(roomID)
    }
    
}

class RoomDB {
    private var DB: DBModel
    private var user: Connection
    private var roomTable: Table
    
    private let roomIDExpression = Expression<Int>(ExpressionTitle.RoomID.description)
    private let roomNameExpression = Expression<String>(ExpressionTitle.RoomName.description)
    init() {
        self.DB = DBModel.sharedInstance()
        self.user = DB.getUser()
        
        self.roomTable = Table("roomTable")
        
        try! user.run(roomTable.create(ifNotExists: true) { t in
            t.column(roomIDExpression, primaryKey: true)
            t.column(roomNameExpression)
            })
    }
    
    func reload() {
        DB.reload()
    }
    
    func loadRoomTable() -> [Room]{
        let rows = Array(try! user.prepare(roomTable))
        var rooms: [Room] = [ ]
        for row in rows {
            rooms.append(Room(roomID: row[roomIDExpression], roomName: row[roomNameExpression]))
        }
        return rooms
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
    }
}
