//
//  DTRouteSelectModel.swift
//  DT
//
//  Created by Ye Keyon on 2020/8/11.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import KakaJSON

enum ConnectStatus:Int, ConvertibleEnum {
    case connecting = 0
    case connected = 1
    case disConnect = 2
}

class DTServerGroupResult:DTBaseResult {
    var entry = [DTServerGroupData]()
}

class DTServerGroupData:Convertible {
    var grouoLogo:String = ""
    var groupName:String = ""
    var groupDescription:String = ""
    var groupId:Int = 0
    var isOpen = false
    var serverVOList = [DTServerVOItemData]()
    
    required init() {
    }
    
    func kj_modelKey(from property: Property) -> ModelPropertyKey {
        switch property.name {
        case "groupId":
            return "id"
        default:
            return property.name
        }
    }
}

class DTServerVOItemData: NSObject, Convertible {
    var color:String = ""
    var name:String = ""
    var desc:String = ""
    var domain = ""
    var ping:Double = 0
    var itemId:Int = 0
    var connectFlag:ConnectStatus = .disConnect
    
    required override init() {
    }
    
    func kj_modelKey(from property: Property) -> ModelPropertyKey {
        switch property.name {
        case "itemId":
            return "id"
        case "desc":
            return "description"
        default:
            return property.name
        }
    }
    
}
