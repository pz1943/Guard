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
class Equipment {
    //MARK: -info
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
    var imageAbsoluteFilePath: NSURL? {
        get {
            if imageName != nil {
                return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent(imageName!)
            } else {
                return nil
            }
        }
    }

    var isRecordsNeedReload: Bool {
        get {
            return records.recentNeedRefresh
        }
    }
    private var inspectionDoneFlagCache: Bool = false
    var records: RecordsForEquipment
    
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
        records = RecordsForEquipment(equipmentID: ID, equipmentType: type)
    }
    deinit {
        print("deinit equipment \(ID)")
    }

}
extension Equipment {
    var brief: EquipmentBrief {
        get {
            return EquipmentBrief(ID: ID, name: name, completedFlag: records.completedFlag)
        }
    }
    
    var inspectionDoneFlag: Bool {
        get {
            if isRecordsNeedReload == false {
                print("\(name) use cache")
                return inspectionDoneFlagCache
            } else {
                print("\(name) use reload")

                inspectionDoneFlagCache = records.completedFlag
                return inspectionDoneFlagCache
            }
        }
    }
}


struct EquipmentDetailArrayWithTitle {
    var equipment: Equipment
    var editableDetailArray: [EquipmentDetail] = []
    var detailArray: [EquipmentDetail]
    init(equipment: Equipment) {
        self.equipment = equipment
        editableDetailArray.append(EquipmentDetail(title: ExpressionTitle.EQName, info: "\(equipment.name)"))
        editableDetailArray.append(EquipmentDetail(title: ExpressionTitle.EQBrand, info: equipment.brand))
        editableDetailArray.append(EquipmentDetail(title: ExpressionTitle.EQModel, info: equipment.model))
        editableDetailArray.append(EquipmentDetail(title: ExpressionTitle.EQCapacity, info: equipment.capacity))
        editableDetailArray.append(EquipmentDetail(title: ExpressionTitle.EQCommissionTime, info: equipment.commissionTime))
        editableDetailArray.append(EquipmentDetail(title: ExpressionTitle.EQSN, info: equipment.SN))
        detailArray = editableDetailArray
        detailArray.insert(EquipmentDetail(title: ExpressionTitle.RoomName, info: "\(equipment.roomName)"), atIndex: 1)
        detailArray.insert(EquipmentDetail(title: ExpressionTitle.EQType, info: "\(equipment.type)"), atIndex: 1)
        detailArray.insert(EquipmentDetail(title: ExpressionTitle.EQID, info: "\(equipment.ID)"), atIndex: 1)
    }
    var count: Int {
        get {
            return self.detailArray.count
        }
    }
    
    subscript(index: Int) -> EquipmentDetail {
        get {
            return detailArray[index]
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
    private var db: Connection
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
        self.db = DBModel.sharedInstance().getDB()
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
    
    func addEquipment(equipmentName: String, equipmentType: String, roomID: Int, roomName: String) {
        let insert = equipmentTable.insert(
            self.equipmentNameExpression <- equipmentName,
            self.equipmentTypeExpression <- equipmentType,
            self.roomIDExpression <- roomID,
            self.roomNameExpression <- roomName)
        do {
            try db.run(insert)
        } catch let error as NSError {
            print(error)
        }
    }
    
    func delEquipment(equipmentToDel: Int) {
        let alice = equipmentTable.filter(self.equipmentIDExpression == equipmentToDel)
        do {
            try db.run(alice.delete())
        } catch let error as NSError {
            print(error)
        }
    }
    func loadEquipmentTable(roomID: Int) -> [Equipment]{
        let rows = Array(try! db.prepare(equipmentTable.filter(self.roomIDExpression == roomID)))
        var equipments: [Equipment] = [ ]
        for row in rows {
            equipments.append(
                Equipment(ID: row[equipmentIDExpression],
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
        return equipments
    }
    
    func loadEquipment(equipmentID: Int) -> Equipment? {
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
            
            return Equipment(ID: equipmentID, name: name, type: EQType!, roomID: locatedRoomID!, roomName: locatedRoomName!, brand: brand, model: model, capacity: capacity, commissionTime: commissionTime, SN: SN, imageName: ImageName)
            
        } else {
            return nil
        }
    }
    
    func editEquipment(equipment: Equipment) {
        let alice = equipmentTable.filter(self.equipmentIDExpression == equipment.ID)
        for equipmentDetail in EquipmentDetailArrayWithTitle(equipment: equipment).editableDetailArray {
            do {
                try db.run(alice.update(Expression<String>("\(equipmentDetail.title)") <- equipmentDetail.info))
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
                try db.run(alice.update(Expression<String?>(equipmentDetailTitleString) <- newValue))
            } else {
                try db.run(alice.update(Expression<String>(equipmentDetailTitleString) <- newValue))
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
}



