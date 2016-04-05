//
//  Created by apple on 15/12/19.
//  Copyright © 2015年 pz1943. All rights reserved.
//

import Foundation
import SQLite

enum ExpressionTitle:  String, CustomStringConvertible{
    case RoomID = "机房ID"
    case RoomName = "机房名称"
    case EQID = "设备ID"
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


class DBModel {
    private var db: Connection
    
    struct Static { 
        static var instance:DBModel? = nil
        static var token:dispatch_once_t = 0
    }
    
    struct Constants {
        static let inspectionDelayHour: Int = 8
    }
    
    func getDB() -> Connection {
        return self.db
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
        print(path)
        db = try! Connection("\(path)/db.sqlite3")
    }
    
    required init() {
        dateFormatter.timeZone = NSTimeZone(name: "Asia/Shanghai")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let path = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true
            ).first!
        db = try! Connection("\(path)/db.sqlite3")
   }
    
}
