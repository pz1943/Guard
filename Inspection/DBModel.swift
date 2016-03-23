//
//  Created by apple on 15/12/19.
//  Copyright © 2015年 pz1943. All rights reserved.
//

import Foundation
import SQLite

enum ExpressionTitle:  String, CustomStringConvertible{
    case RoomID = "机房ID"
    case RoomName = "机房名称"
    case EQID = "设备 ID"
    case EQName = "设备名称"
    case EQType = "设备类型"
    case EQBrand = "设备品牌"
    case EQModel = "设备型号"
    case EQCapacity = "设备容量"
    case EQCommissionTime = "投运时间"
    case EQSN = "设备SN"
    case EQImageName = "图片名称"
    case RecordID = "记录ID"
    case RecordMessage = "检修内容"
    case RecordDate = "时间"
    
    case InspectionTaskID = "类别ID"
    case InspectionTaskName = "类别名称"
    case InspectionCycle = "巡检周期"
    
    case InspectionDelayID = "延时ID"
    case InspectionDelayHour = "延时时间"
    
    var description: String {
        get {
            return self.rawValue
        }
    }
}

class EquipmentDB {
    private var DB: DBModel
    private var user: Connection
    private var equipmentTable: Table
    
    private let roomIDExpression = Expression<Int>(ExpressionTitle.RoomID.description)
    private let roomNameExpression = Expression<String>(ExpressionTitle.RoomName.description)
    private let equipmentIDExpression = Expression<Int>(ExpressionTitle.EQID.description)
    private let equipmentNameExpression = Expression<String>(ExpressionTitle.EQName.description)
    private let equipmentTypeExpression = Expression<String>(ExpressionTitle.EQType.description)
    private let equipmentBrandExpression = Expression<String?>(ExpressionTitle.EQBrand.description)
    private let equipmentModelExpression = Expression<String?>(ExpressionTitle.EQModel.description)
    private let equipmentCapacityExpression = Expression<String?>(ExpressionTitle.EQCapacity.description)
    private let equipmentCommissionTimeExpression = Expression<String?>(ExpressionTitle.EQCommissionTime.description)
    private let equipmentSNExpression = Expression<String?>(ExpressionTitle.EQSN.description)
    private let equipmentImageNameExpression = Expression<String?>(ExpressionTitle.EQImageName.description)

    init() {
        self.DB = DBModel.sharedInstance()
        self.user = DB.getUser()
        self.equipmentTable = Table("equipmentTable")
        
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
    func loadEquipmentTable(roomID: Int) -> [Equipment]{
        let rows = Array(try! user.prepare(equipmentTable.filter(self.roomIDExpression == roomID)))
        var equipments: [Equipment] = [ ]
        for row in rows {
            equipments.append(
                Equipment(ID: row[equipmentIDExpression],
                    name: row[equipmentNameExpression],
                    type: row[equipmentTypeExpression],
                    roomID: row[roomIDExpression],
                    roomName: row[roomNameExpression]))
        }
        return equipments
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
        for equipmentDetail in EquipmentDetailArrayWithTitle(equipment: equipment).editableDetailArray {
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
            if equipmentDetailTitleString != ExpressionTitle.EQName.description {
                try user.run(alice.update(Expression<String?>(equipmentDetailTitleString) <- newValue))
            } else {
                try user.run(alice.update(Expression<String>(equipmentDetailTitleString) <- newValue))
            }
        } catch let error as NSError {
            print(error)
        }
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

class RecordDB {
    private var DB: DBModel
    private var user: Connection
    private var recordTable: Table
    
    private let equipmentIDExpression = Expression<Int>(ExpressionTitle.EQID.description)
    private let recordIDExpression = Expression<Int>(ExpressionTitle.RecordID.description)
    private let recordMessageExpression = Expression<String?>(ExpressionTitle.RecordMessage.description)
    private let inspectionTaskNameExpression = Expression<String>(ExpressionTitle.InspectionTaskName.description)
    private let recordDateExpression = Expression<NSDate>(ExpressionTitle.RecordDate.description)

    init() {
        self.DB = DBModel.sharedInstance()
        self.user = DB.getUser()
        self.recordTable = Table("recordTable")
        
        try! user.run(recordTable.create(ifNotExists: true) { t in
            t.column(recordIDExpression, primaryKey: true)
            t.column(equipmentIDExpression)
            t.column(inspectionTaskNameExpression)
            t.column(recordMessageExpression)
            t.column(recordDateExpression)
            })
    }
    
    func addRecord(record: Record) {
        let insert = recordTable.insert(self.recordMessageExpression <- record.message,
            self.inspectionTaskNameExpression <- record.taskType,
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
            let record = Record(recordID: row[self.recordIDExpression], equipmentID: row[self.equipmentIDExpression], date: row[recordDateExpression], task: row[inspectionTaskNameExpression], recordData: row[recordMessageExpression])
            recordArray.insert(record, atIndex: 0)
        }
        return recordArray
    }
    func loadRecordFromRecordID(recordID: Int) -> Record {
        let alice = recordTable.filter(self.recordIDExpression == recordID)
        let row = Array(try! user.prepare(alice)).first!
        let record = Record(recordID: row[self.recordIDExpression], equipmentID: row[self.equipmentIDExpression], date: row[recordDateExpression], task: row[inspectionTaskNameExpression], recordData: row[recordMessageExpression])
        return record
        
    }
    
    func loadRecentTimeForType(equipmentID: Int, inspectionTask: String) -> Record? {
        let alice = recordTable.filter(self.equipmentIDExpression == equipmentID && self.inspectionTaskNameExpression == inspectionTask)
        if let lastRecordID = user.scalar(alice.select(recordIDExpression.max)) {
            let record = loadRecordFromRecordID(lastRecordID)
            return record
        } else {
            return nil
        }
    }
}

class InspectionTaskDB {
    private var DB: DBModel
    private var user: Connection
    private var inspectionTaskTable: Table
    
    private let inspectionTaskIDExpression = Expression<Int>(ExpressionTitle.InspectionTaskID.description)
    private let inspectionCycleExpression = Expression<Double>(ExpressionTitle.InspectionCycle.description)
    private let equipmentIDExpression = Expression<Int>(ExpressionTitle.EQID.description)
    private let equipmentTypeExpression = Expression<String>(ExpressionTitle.EQType.description)
    private let inspectionTaskNameExpression = Expression<String>(ExpressionTitle.InspectionTaskName.description)

    init() {
        self.DB = DBModel.sharedInstance()
        self.user = DB.getUser()
        self.inspectionTaskTable = Table("inspectionTaskTable")
        
        try! user.run(inspectionTaskTable.create(ifNotExists: true) { t in
            t.column(inspectionTaskIDExpression, primaryKey: true)
            t.column(inspectionTaskNameExpression)
            t.column(equipmentTypeExpression)
            t.column(inspectionCycleExpression)
            })
    }

    func loadInspectionTaskDir() -> [String: [InspectionTask]] {
        let rows = Array(try! user.prepare(inspectionTaskTable))
        var inspectionTaskDir: [String: [InspectionTask]] = [: ]
        for row in rows {
            let type = InspectionTask(
                equipmentType: row[equipmentTypeExpression],
                inspectionTaskName: row[inspectionTaskNameExpression],
                inspectionCycle: row[inspectionCycleExpression])
            if inspectionTaskDir[type.equipmentType] != nil {
                inspectionTaskDir[type.equipmentType]?.append(type)
            } else {
                inspectionTaskDir[type.equipmentType] = [type]
            }
        }
        return inspectionTaskDir
    }
    
    func addInspectionTask(type: InspectionTask) -> Bool {
        let insert = inspectionTaskTable.insert(
            self.inspectionTaskNameExpression <- type.inspectionTaskName,
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
    
}

class InspectionDelayDB {
    private var DB: DBModel
    private var user: Connection
    private var inspectionDelayTable: Table

    private let inspectionDelayIDExpression = Expression<Int>("inspectionDelayID")
    private let inspectionDelayHourExpression = Expression<Int>("inspectionDelayHour")
    private let inspectionTaskNameExpression = Expression<String>(ExpressionTitle.InspectionTaskName.description)
    private let equipmentIDExpression = Expression<Int>(ExpressionTitle.EQID.description)
    
    init() {
        self.DB = DBModel.sharedInstance()
        self.user = DB.getUser()
        self.inspectionDelayTable = Table("inspectionDelayTable")
        
        try! user.run(inspectionDelayTable.create(ifNotExists: true) { t in
            t.column(inspectionDelayIDExpression, primaryKey: true)
            t.column(equipmentIDExpression)
            t.column(inspectionTaskNameExpression)
            t.column(inspectionDelayHourExpression)
            })
    }
    
    func editInspectionDelayHourForEquipment(equipmentID: Int, inspectionTask: String, hours: Int) {
        let alice = inspectionDelayTable.filter(self.equipmentIDExpression == equipmentID && self.inspectionTaskNameExpression == inspectionTask)
        do {
            try user.run(alice.update(Expression<Int>(inspectionDelayHourExpression) <- hours))
        } catch let error as NSError {
            print(error)
        }
    }
    
    func addInspectionDelayForEquipment(equipmentID: Int, inspectionTask: String, hours: Int) {
        let insert = inspectionDelayTable.insert(self.inspectionTaskNameExpression <- inspectionTask,
            self.equipmentIDExpression <- equipmentID,
            self.inspectionTaskNameExpression <- inspectionTask,
            self.inspectionDelayHourExpression <- hours
        )
        do {
            try user.run(insert)
        } catch let error as NSError {
            print(error)
        }
    }

}

class DBModel {
    private var user: Connection
    
    struct Static {
        static var instance:DBModel? = nil
        static var token:dispatch_once_t = 0
    }
    
    struct Constants {
        static let inspectionDelayHour: Int = 8
    }
    
    func getUser() -> Connection {
        return self.user
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
        user = try! Connection("\(path)/db.sqlite3")
    }
    
    required init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true
            ).first!
        user = try! Connection("\(path)/db.sqlite3")
   }
    
}
