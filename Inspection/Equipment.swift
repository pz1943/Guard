//
//  Equipment.swift
//  Inspection
//
//  Created by apple on 16/1/16.
//  Copyright © 2016年 pz1943. All rights reserved.
//

import Foundation
import SQLite


class Equipment {
    
    typealias EquipmentDetailArray = [EquipmentDetail]
    struct EquipmentDetail {
        var title: EquipmentTableColumnTitle
        var info: String
        
        init(title: EquipmentTableColumnTitle, info: String?) {
            self.title = title
            if info != nil {
                self.info = info!
            } else {
                self.info = "暂无"
            }
        }
    }
    
    var ID: Int
    var name: String
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
            detail.insert(EquipmentDetail(title: EquipmentTableColumnTitle.RoomName, info: "\(self.roomName)"), atIndex: 1)
            return detail
        }
    }
    
    var editableDetailArray: EquipmentDetailArray {
        get {
            var detail: [EquipmentDetail] = []
            detail.insert(EquipmentDetail(title: EquipmentTableColumnTitle.Name, info: "\(self.name)"), atIndex: 0)
            detail.append(EquipmentDetail(title: EquipmentTableColumnTitle.Brand, info: self.brand))
            detail.append(EquipmentDetail(title: EquipmentTableColumnTitle.Model, info: self.model))
            detail.append(EquipmentDetail(title: EquipmentTableColumnTitle.Capacity, info: self.capacity))
            detail.append(EquipmentDetail(title: EquipmentTableColumnTitle.CommissionTime, info: self.commissionTime))
            detail.append(EquipmentDetail(title: EquipmentTableColumnTitle.SN, info: self.SN))
            return detail
        }
    }
    
    init(ID: Int,
        name: String,
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

