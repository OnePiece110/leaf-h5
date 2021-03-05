//
//  DTTunnelInbounds.swift
//  Tunnel
//
//  Created by Ye Keyon on 2020/12/28.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import KakaJSON

enum DTInboundsProtocol:String, ConvertibleEnum {
    case tun
    case http
    case socks
}

class DTTunnelInbounds: Convertible {
    var proto: DTInboundsProtocol = .tun
    var settings: DTTunnelTunSetting?
    
    required init() {}
    
    init(fd: Int32) {
        proto = .tun
        settings = DTTunnelTunSetting()
        settings?.fd = fd
    }
    
    
    func kj_JSONKey(from property: Property) -> JSONPropertyKey {
        switch property.name {
        case "proto":
            return "protocol"
        default:
            return property.name
        }
    }
    
    func kj_modelKey(from property: Property) -> ModelPropertyKey {
        switch property.name {
        case "proto": return "protocol"
        default: return property.name
        }
    }
    
}


class DTTunnelTunSetting: Convertible {
    var fd:Int32?
    var fakeDnsInclude:[String]?
    var fakeDnsExclude:[String]?
    
    required init() {}
}
