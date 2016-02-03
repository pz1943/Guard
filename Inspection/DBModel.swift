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
    
    let equipmentID = Expression<Int>(EquipmentTableColumn.ID.rawValue)
    let equipmentName = Expression<String>(EquipmentTableColumn.Name.rawValue)
    let equipmentBrand = Expression<String?>(EquipmentTableColumn.Brand.rawValue)
    let equipmentModel = Expression<String?>(EquipmentTableColumn.Model.rawValue)
    let equipmentCapacity = Expression<String?>(EquipmentTableColumn.Capacity.rawValue)
    let equipmentCommissionTime = Expression<String?>(EquipmentTableColumn.CommissionTime.rawValue)
    let equipmentSN = Expression<String?>(EquipmentTableColumn.SN.rawValue)
    let equipmentImageName = Expression<String?>(EquipmentTableColumn.ImageName.rawValue)
    
    let recordID = Expression<Int>("recordID")
    let recordMessage = Expression<String?>("recordMessage")
    let recordType = Expression<String>("recordType")
    let recordDate = Expression<NSDate>("recordDate")
    
   
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
        if inspectionTimeDir.count < Inspection.timeCycleDir.count {
            return false
        }
        for (type, date) in inspectionTimeDir {
            if let timeCycle = Inspection.timeCycleDir[type]{
                if -date.timeIntervalSinceNow.datatypeValue > Double(timeCycle) * 24 * 3600{
                    print(date.timeIntervalSinceNow.datatypeValue)
                    return false
                } else {
                    print("\(type),\(date.timeIntervalSinceNow), \(Double(timeCycle) * 24 * 3600)")
                }
            }
        }
        return true
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
                try DB.run(alice.update(Expression<String>("\(equipmentDetail.title.rawValue)") <- equipmentDetail.info))
            } catch let error as NSError {
                print(error)
            }
        }
    }
// to edit one singel Detail
    func editEquipment(equipmentID: Int, equipmentDetailTitleString: String, newValue: String) {
        let alice = equipmentTable.filter(self.equipmentID == equipmentID)
        do {
            if let expressionString = titleStringToExpressionString(equipmentDetailTitleString) {
                if expressionString != EquipmentTableColumn.Name.rawValue {
                    try DB.run(alice.update(Expression<String?>(expressionString) <- newValue))
                } else {
                    try DB.run(alice.update(Expression<String>(expressionString) <- newValue))
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    func titleStringToExpressionString(title: String) -> String? {
        switch title {
        case "设备 ID":
            return EquipmentTableColumn.ID.rawValue
        case "设备名称":
            return EquipmentTableColumn.Name.rawValue
        case "机房 ID":
            return EquipmentTableColumn.RoomID.rawValue
        case "机房名称":
            return EquipmentTableColumn.RoomName.rawValue
        case "设备品牌":
            return EquipmentTableColumn.Brand.rawValue
        case "设备型号":
            return EquipmentTableColumn.Model.rawValue
        case "设备容量":
            return EquipmentTableColumn.Capacity.rawValue
        case "投运时间":
            return EquipmentTableColumn.CommissionTime.rawValue
        case "设备 SN":
            return EquipmentTableColumn.SN.rawValue
        case "图片名称":
            return EquipmentTableColumn.ImageName.rawValue
        default:
            return nil
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

enum EquipmentTableColumn: String{
    case ID = "equipmentID"
    case Name = "equipmentName"
    case RoomID = "roomID"
    case RoomName = "roomName"
    case Brand = "equipmentBrand"
    case Model = "equipmentModel"
    case Capacity = "equipmentCapacity"
    case CommissionTime = "equipmentCommissionTime"
    case SN = "equipmentSN"
    case ImageName = "equipmentImageName"
}

enum EquipmentTableColumnTitle: String{
    case ID = "设备 ID"
    case Name = "设备名称"
    case RoomID = "机房 ID"
    case RoomName = "机房名称"
    case Brand = "设备品牌"
    case Model = "设备型号"
    case Capacity = "设备容量"
    case CommissionTime = "投运时间"
    case SN = "设备 SN"
    case ImageName = "图片名称"
}


struct Inspection {
    static let Daily = "日巡视"
    static let Weekly = "周测试"
    static let FilterChanging = "滤网更换"
    static let Cleaning = "室外机清洁"
    static let BeltChanging = "皮带更换"
    static let HumidifyingCansChanging = "加湿罐更换"
    static let Quarterly = "季度测试"
    
    static func getType() -> [String] {
        return [Daily, Weekly, Quarterly, FilterChanging, Cleaning, BeltChanging, HumidifyingCansChanging]
    }
    
    static let typeCount = [Daily, Weekly, Quarterly, FilterChanging, Cleaning, BeltChanging, HumidifyingCansChanging].count
    
    static let timeCycle: [(String, Double)] = [ (Daily, 0.01),
        (Weekly, 7),
        (FilterChanging, 90),
        (Cleaning, 90),
        (BeltChanging, 180),
        (HumidifyingCansChanging, 90),
        (Quarterly, 90)]
    
    static let timeCycleDir: [String: Double] = [ Daily: 0.001,
        Weekly: 7,
        FilterChanging: 90,
        Cleaning: 90,
        BeltChanging: 180,
        HumidifyingCansChanging: 90,
        Quarterly: 90]
}

struct RoomBrief {
    var roomName: String
    var roomID: Int
    var isRoomInspectonCompleted: Bool
    
    init(ID: Int, name: String, completedFlag: Bool){
        self.roomName = name
        self.roomID = ID
        self.isRoomInspectonCompleted = completedFlag
    }
}

struct EquipmentBrief {
    var equipmentName: String
    var equipmentID: Int
    var isequipmentInspectonCompleted: Bool
    
    init(ID: Int, name: String, completedFlag: Bool){
        self.equipmentName = name
        self.equipmentID = ID
        self.isequipmentInspectonCompleted = completedFlag
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
    var dateForString: String {
        get {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.timeStyle = .ShortStyle
            return dateFormatter.stringFromDate(self.date)
        }
    }
    //add a new Record
    init(equipmentID: Int, type: String, recordData: String?) {
        self.equipmentID = equipmentID
        self.recordType = type
        self.message = recordData
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        //        dateFormatter.weekdaySymbols = ["星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"]
        //        dateFormatter.monthSymbols = ["一月", "二月", "三月", "四月", "五月", "六月","七月", "八月", "九月", "十月", "十一月", "十二月"]
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