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
    
    let records: RecordsForEquipment
    let DB: DBModel = DBModel.sharedInstance()
    
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
    var brief: EquipmentBrief {
        get {
            return EquipmentBrief(ID: ID, name: name, completedFlag: records.completedFlag)
        }
    }
    
    var inspectionDoneFlag: Bool {
        get {
            return records.completedFlag
        }
    }
}


struct EquipmentDetailArrayWithTitle {
    var equipment: Equipment
    var editableDetailArray: [EquipmentDetail] = []
    var detailArray: [EquipmentDetail]
    init(equipment: Equipment) {
        self.equipment = equipment
        editableDetailArray.append(EquipmentDetail(title: EquipmentInfoTitle.Name, info: "\(equipment.name)"))
        editableDetailArray.append(EquipmentDetail(title: EquipmentInfoTitle.Brand, info: equipment.brand))
        editableDetailArray.append(EquipmentDetail(title: EquipmentInfoTitle.Model, info: equipment.model))
        editableDetailArray.append(EquipmentDetail(title: EquipmentInfoTitle.Capacity, info: equipment.capacity))
        editableDetailArray.append(EquipmentDetail(title: EquipmentInfoTitle.CommissionTime, info: equipment.commissionTime))
        editableDetailArray.append(EquipmentDetail(title: EquipmentInfoTitle.SN, info: equipment.SN))
        detailArray = editableDetailArray
        detailArray.insert(EquipmentDetail(title: EquipmentInfoTitle.RoomName, info: "\(equipment.roomName)"), atIndex: 1)
        detailArray.insert(EquipmentDetail(title: EquipmentInfoTitle.EQType, info: "\(equipment.type)"), atIndex: 1)
        detailArray.insert(EquipmentDetail(title: EquipmentInfoTitle.ID, info: "\(equipment.ID)"), atIndex: 1)
    }
}
struct EquipmentDetail {
    var title: String
    var info: String
    
    init(title: EquipmentInfoTitle, info: String?) {
        self.title = title.titleInChinese
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

enum EquipmentInfoTitle: String{
    case ID = "设备 ID"
    case Name = "设备名称"
    case EQType = "设备类型"
    case RoomID = "机房 ID"
    case RoomName = "机房名称"
    case Brand = "设备品牌"
    case Model = "设备型号"
    case Capacity = "设备容量"
    case CommissionTime = "投运时间"
    case SN = "设备 SN"
    case ImageName = "图片名称"
    
    var titleInChinese: String {
        get {
            return self.rawValue
        }
    }
}

