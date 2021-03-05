//
//  DTServerDetailData.swift
//  Tunnel
//
//  Created by Ye Keyon on 2020/12/24.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import KakaJSON

class DTServerDetaiResult: DTBaseResult {
    var entry = DTServerDetailData()
}

class DTServerDetailData:Convertible {
    var itemId:Int = 0
    var domain = ""
    var port = 0
    var proto = 0
    var name = ""
    var passwd = ""
    var ip = ""
    var path = ""
    var testProto = ""
    var host = ""
    
    required init() {
    }
    
    func kj_modelKey(from property: Property) -> ModelPropertyKey {
        switch property.name {
        case "itemId":
            return "id"
        case "proto":
            return "protocol"
        default:
            return property.name
        }
    }
}
