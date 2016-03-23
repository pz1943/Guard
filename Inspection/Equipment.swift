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
    
    var isRecordsNeedReload: Bool = true
    var inspectionDoneFlagCache: Bool = true
    let records: RecordsForEquipment
    
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
    
    convenience init(ID: Int, name: String, type: EquipmentType, roomID: Int, roomName: String) {
        self.init(ID: ID,
            name: name,
            type: type,
            roomID: roomID,
            roomName: roomName,
            brand: nil,
            model: nil,
            capacity: nil,
            commissionTime: nil,
            SN: nil,
            imageName: nil)
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
                return inspectionDoneFlagCache
            } else {
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
            return self.editableDetailArray.count
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


