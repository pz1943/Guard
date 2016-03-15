//
//  Equipment.swift
//  Inspection
//
//  Created by apple on 16/1/16.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import Foundation
import SQLite

struct Record {
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
    //add a new Record
    init(equipmentID: Int, type: String, recordData: String?) {
        self.equipmentID = equipmentID
        self.recordType = type
        self.message = recordData
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

typealias EquipmentDetailArray = [Equipment.EquipmentDetail]
typealias EquipmentBrief = Equipment.EquipmentBrief

class Equipment {
    //MARK: -info
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
    
    let DB: DBModel = DBModel.sharedInstance()
    let types: [InspectionType]

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
        
        types = DB.loadInspectionTypeDir().getInspectionTypeArrayForEquipmentType(self.type)
    }
    
    convenience init(ID: Int, name: String, type: String, roomID: Int, roomName: String) {
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
//MARK:- TitleArray
    static let RequiredTitleArray = [
        EquipmentInfoTitle.Name,
        EquipmentInfoTitle.EQType,
        EquipmentInfoTitle.ID
    ]
    static let OptionalTitleArray = [
        EquipmentInfoTitle.Brand,
        EquipmentInfoTitle.Model,
        EquipmentInfoTitle.Capacity,
        EquipmentInfoTitle.CommissionTime,
        EquipmentInfoTitle.SN,
        EquipmentInfoTitle.ImageName
    ]
    static var EquipmentInfoTitleArray: [EquipmentInfoTitle] {
        get {
            return RequiredTitleArray + OptionalTitleArray
        }
    }

   //MARK:- records
    var recordsArray:[Record] {
        get {
            return DB.loadRecordFromEquipmetID(ID)
        }
    }
    var mostRecentRecordsDir:[String: NSDate] {
        get {
            var recordsDir: [String: NSDate] = [: ]
            for type in types {
                if let record = DB.loadRecentTimeForType(ID, inspectionType: type.inspectionTypeName) {
                    recordsDir[type.inspectionTypeName] = record.date
                }
            }
            return recordsDir
        }
    }
    
    func isEquipmentCompleted() -> Bool{
        for type in types {
            if isEquipmentCompletedForType(type) == false {
                return false
            }
        }
        return true
    }
    
    func isEquipmentCompletedForType(inspectionType: InspectionType) -> Bool {
        if equipmentType == nil {
            return false
        }
        let timeCycleDir = self.loadInspectionTypeDir()
        if let timeCycle = timeCycleDir.getTimeCycleForEquipment(equipmentType!, type: type){
            if -date.timeIntervalSinceNow.datatypeValue > Double(timeCycle) * 24 * 3600{
                return false
            }
        }
        return true
        
    }
    
    var completedFlag: Bool {
        return isEquipmentCompleted()
    }
    var brief: EquipmentBrief {
        get {
            return EquipmentBrief(ID: ID, name: name, completedFlag: completedFlag)
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
    
    
}

