//
//  Equipment.swift
//  Inspection
//
//  Created by apple on 16/1/16.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import Foundation
import SQLite

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

class Equipment {
    
    typealias EquipmentDetailArray = [EquipmentDetail]
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
    
    static let RequiredEquipmentInfoTitleArray = [
        EquipmentInfoTitle.Name,
        EquipmentInfoTitle.EQType,
        EquipmentInfoTitle.ID
    ]
    static let OptionalEquipmentInfoTitleArray = [
        EquipmentInfoTitle.Brand,
        EquipmentInfoTitle.Model,
        EquipmentInfoTitle.Capacity,
        EquipmentInfoTitle.CommissionTime,
        EquipmentInfoTitle.SN,
        EquipmentInfoTitle.ImageName
    ]
    static var EquipmentInfoTitleArray: [EquipmentInfoTitle] {
        get {
            return RequiredEquipmentInfoTitleArray + OptionalEquipmentInfoTitleArray
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
    
    var ID: Int
    var name: String
    var type: String
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
    var detailArray: EquipmentDetailArray {
        get {
            var detail = self.editableDetailArray
            detail.insert(EquipmentDetail(title: EquipmentInfoTitle.RoomName, info: "\(self.roomName)"), atIndex: 1)
            detail.insert(EquipmentDetail(title: EquipmentInfoTitle.EQType, info: "\(self.type)"), atIndex: 1)
            detail.insert(EquipmentDetail(title: EquipmentInfoTitle.ID, info: "\(self.ID)"), atIndex: 1)
            return detail
        }
    }
    
    var editableDetailArray: EquipmentDetailArray {
        get {
            var detail: [EquipmentDetail] = []
            detail.insert(EquipmentDetail(title: EquipmentInfoTitle.Name, info: "\(self.name)"), atIndex: 0)
            detail.append(EquipmentDetail(title: EquipmentInfoTitle.Brand, info: self.brand))
            detail.append(EquipmentDetail(title: EquipmentInfoTitle.Model, info: self.model))
            detail.append(EquipmentDetail(title: EquipmentInfoTitle.Capacity, info: self.capacity))
            detail.append(EquipmentDetail(title: EquipmentInfoTitle.CommissionTime, info: self.commissionTime))
            detail.append(EquipmentDetail(title: EquipmentInfoTitle.SN, info: self.SN))
            return detail
        }
    }
    
    init(ID: Int,
        name: String,
        type: String,
        roomID: Int,
        roomName: String,
        brand: String?,
        model: String?,
        capacity: String?,
        commissionTime: String?,
        SN: String?,
        imageName: String?
        )
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

