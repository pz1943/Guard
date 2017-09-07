//
//  Equipment.swift
//  Inspection
//
//  Created by apple on 16/1/16.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import Foundation
import SQLite

typealias EquipmentType = String

class EquipmentArray {
    var arr: [Equipment]
    
    init(roomID: Int) {
        arr = []
        for info in EquipmentDB().loadEquipmentTable(roomID) {
            arr.append(Equipment(info: info))
        }
    }
}

class EquipmentInfo {

    var ID: Int
    var name: String
    var type: EquipmentType
    var roomID: Int
    var roomName: String
    var brand: String?
    var model: String?
    var capacity: String?
    var commissionTime: String?
    var SN: String?
    var imageName: String?
    
    init(ID: Int,
        name: String,
        type: EquipmentType,
        roomID: Int,
        roomName: String,
        brand: String?,
        model: String?,
        capacity: String?,
        commissionTime: String?,
        SN: String?,
        imageName: String?)
    {
        self.ID = ID
        self.name = name
        self.type = type
        self.roomID = roomID
        self.roomName = roomName
        self.brand = brand
        self.model = model
        self.capacity = capacity
        self.commissionTime = commissionTime
        self.SN = SN
        self.imageName = imageName
    }
}

class Equipment {
    //MARK: -info
    var info: EquipmentInfo
    var inspectionTaskArray: [InspectionTask]
    var detailArray: EquipmentDetailArrayWithTitle
    var records: RecordsForEquipment
    
    init(info: EquipmentInfo) {
        self.info = info
        self.detailArray = EquipmentDetailArrayWithTitle(info: info)
        self.inspectionTaskArray = InspectionTaskDir().getTaskArray(info.type)
        self.records = RecordsForEquipment(info: info, taskArray: inspectionTaskArray)
    }
    
    init(ID: Int) {
        self.info = EquipmentDB().loadEquipmentInfo(ID)!
        self.detailArray = EquipmentDetailArrayWithTitle(info: info)
        self.inspectionTaskArray = InspectionTaskDir().getTaskArray(info.type)
        self.records = RecordsForEquipment(info: info, taskArray: inspectionTaskArray)

    }
    
    func removeFromDB() {
        EquipmentDB().delEquipment(info.ID)
        DelayDB().delDelayForEquipment(info.ID)
    }
    
    var imageAbsoluteFilePath: URL? {
        get {
            if info.imageName != nil {
                return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(info.imageName!)
            } else {
                return nil
            }
        }
    }
    
    func reloadInfo() {
        if let info = EquipmentDB().loadEquipmentInfo(self.info.ID) {
            self.info = info
            self.detailArray = EquipmentDetailArrayWithTitle(info: info)
        }
    }    

    var brief: EquipmentBrief {
        get {
            return EquipmentBrief(ID: info.ID, name: info.name, completedFlag: records.completedFlag)
        }
    }
    
    var inspectionDoneFlag: Bool {
        get {
            return records.completedFlag
        }
    }
}


struct EquipmentDetailArrayWithTitle {
    var info: EquipmentInfo
    var editableDetailArray: [EquipmentDetail] = []
    var allDetailArray: [EquipmentDetail]
    init(info: EquipmentInfo) {
        self.info = info
        editableDetailArray.append(EquipmentDetail(title: ExpressionTitle.EQName, info: "\(info.name)"))
        editableDetailArray.append(EquipmentDetail(title: ExpressionTitle.EQBrand, info: info.brand))
        editableDetailArray.append(EquipmentDetail(title: ExpressionTitle.EQModel, info: info.model))
        editableDetailArray.append(EquipmentDetail(title: ExpressionTitle.EQCapacity, info: info.capacity))
        editableDetailArray.append(EquipmentDetail(title: ExpressionTitle.EQCommissionTime, info: info.commissionTime))
        editableDetailArray.append(EquipmentDetail(title: ExpressionTitle.EQSN, info: info.SN))
        allDetailArray = editableDetailArray
        allDetailArray.insert(EquipmentDetail(title: ExpressionTitle.RoomName, info: "\(info.roomName)"), at: 1)
        allDetailArray.insert(EquipmentDetail(title: ExpressionTitle.EQType, info: "\(info.type)"), at: 1)
        allDetailArray.insert(EquipmentDetail(title: ExpressionTitle.EQID, info: "\(info.ID)"), at: 1)
    }
    var count: Int {
        get {
            return self.allDetailArray.count
        }
    }
    
    subscript(index: Int) -> EquipmentDetail {
        get {
            return allDetailArray[index]
        }
    }

}
struct EquipmentDetail {
    var title: String
    var info: String
    
    init(title: ExpressionTitle, info: String?) {
        self.title = title.description
        if info != nil {
            self.info = info!
        } else {
            self.info = ""
        }
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

class EquipmentDB {
    fileprivate var db: Connection
    fileprivate var equipmentTable: Table
    
    fileprivate let roomIDExpression = Expression<Int>(ExpressionTitle.RoomID.description)
    fileprivate let roomNameExpression = Expression<String>(ExpressionTitle.RoomName.description)
    fileprivate let equipmentIDExpression = Expression<Int>(ExpressionTitle.EQID.description)
    fileprivate let equipmentNameExpression = Expression<String>(ExpressionTitle.EQName.description)
    fileprivate let equipmentTypeExpression = Expression<String>(ExpressionTitle.EQType.description)
    fileprivate let equipmentBrandExpression = Expression<String?>(ExpressionTitle.EQBrand.description)
    fileprivate let equipmentModelExpression = Expression<String?>(ExpressionTitle.EQModel.description)
    fileprivate let equipmentCapacityExpression = Expression<String?>(ExpressionTitle.EQCapacity.description)
    fileprivate let equipmentCommissionTimeExpression = Expression<String?>(ExpressionTitle.EQCommissionTime.description)
    fileprivate let equipmentSNExpression = Expression<String?>(ExpressionTitle.EQSN.description)
    fileprivate let equipmentImageNameExpression = Expression<String?>(ExpressionTitle.EQImageName.description)
    
    init() {
        self.db = DBModel.sharedInstance.getDB()
        self.equipmentTable = Table("equipmentTable")
        
        try! db.run(equipmentTable.create(ifNotExists: true) { t in
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
    
    func addEquipment(_ equipmentName: String, equipmentType: String, roomID: Int, roomName: String) {
        let insert = equipmentTable.insert(
            self.equipmentNameExpression <- equipmentName,
            self.equipmentTypeExpression <- equipmentType,
            self.roomIDExpression <- roomID,
            self.roomNameExpression <- roomName)
        do {
            _ = try db.run(insert)
        } catch let error as NSError {
            print(error)
        }
    }
    
    func delEquipment(_ equipmentToDel: Int) {
        let alice = equipmentTable.filter(self.equipmentIDExpression == equipmentToDel)
        do {
            _ = try db.run(alice.delete())
        } catch let error as NSError {
            print(error)
        }
    }
    func loadEquipmentTable(_ roomID: Int) -> [EquipmentInfo]{
        let rows = Array(try! db.prepare(equipmentTable.filter(self.roomIDExpression == roomID)))
        var info: [EquipmentInfo] = [ ]
        for row in rows {
            info.append(
                EquipmentInfo(ID: row[equipmentIDExpression],
                    name: row[equipmentNameExpression],
                    type: row[equipmentTypeExpression],
                    roomID: row[roomIDExpression],
                    roomName: row[roomNameExpression],
                    brand: row[equipmentBrandExpression],
                    model: row[equipmentModelExpression],
                    capacity: row[equipmentCapacityExpression],
                    commissionTime: row[equipmentCommissionTimeExpression],
                    SN: row[equipmentSNExpression],
                    imageName: row[equipmentImageNameExpression]
                ))
        }
        return info
    }
    
    func loadEquipmentInfo(_ equipmentID: Int) -> EquipmentInfo? {
        let row = Array(try! db.prepare(equipmentTable.filter(self.equipmentIDExpression == equipmentID))).first
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
            
            return EquipmentInfo(ID: equipmentID, name: name, type: EQType!, roomID: locatedRoomID!, roomName: locatedRoomName!, brand: brand, model: model, capacity: capacity, commissionTime: commissionTime, SN: SN, imageName: ImageName)
        } else {
            return nil
        }
    }
    
    func editEquipment(_ equipment: Equipment) {
        let alice = equipmentTable.filter(self.equipmentIDExpression == equipment.info.ID)
        for equipmentDetail in equipment.detailArray.editableDetailArray {
            do {
                _ = try db.run(alice.update(Expression<String>("\(equipmentDetail.title)") <- equipmentDetail.info))
            } catch let error as NSError {
                print(error)
            }
        }
    }
    // to edit one singel Detail
    func editEquipment(_ equipmentID: Int, equipmentDetailTitleString: String, newValue: String) {
        let alice = equipmentTable.filter(self.equipmentIDExpression == equipmentID)
        do {
            if equipmentDetailTitleString != ExpressionTitle.EQName.description {
                _ = try db.run(alice.update(Expression<String?>(equipmentDetailTitleString) <- newValue))
            } else {
                _ = try db.run(alice.update(Expression<String>(equipmentDetailTitleString) <- newValue))
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
}



