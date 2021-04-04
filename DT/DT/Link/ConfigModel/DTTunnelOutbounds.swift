//
//  DTTunnelOutbounds.swift
//  Tunnel
//
//  Created by Ye Keyon on 2020/12/28.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import KakaJSON

enum DTOutboundsProtocol:String, ConvertibleEnum {
    case failover
    case chain
    case tls
    case trojan
    case v2ray
    case shadowsocks
    case vmess
    case vless
    case direct
    case drop
    case ws
    case h2
    
    static func matchPtotocol(proto: Int) -> DTOutboundsProtocol {
        if proto == 20 || proto == 21 {
            return .trojan
        } else if  proto == 22 || proto == 23 {
            return .vless
        } else if proto == 24 {
            return .vmess
        } else {
            return .shadowsocks
        }
    }
}

class DTTunnelOutbounds: Convertible {
    var proto:DTOutboundsProtocol  = .direct
    var tag = ""
    var address:String?
    var port: Int?
    var settings: DTTunnelSettings?
    
    required init() {}
    
    init(proto: DTOutboundsProtocol) {
        
        if proto == .direct {
            self.tag = "direct_out"
        } else if proto == .failover {
            self.tag = "failover_out"
        } else if proto == .drop {
            self.tag = "drop_out"
        }
        self.proto = proto
        switch proto {
        case .direct:
            self.tag = "direct_out"
        case .failover:
            self.tag = "failover_out"
        case .drop:
            self.tag = "drop_out"
        case .chain:
            let settings = DTTunnelSettings()
            settings.actors = [String]()
            self.settings = settings
        case .tls:
            let settings = DTTunnelSettings()
            settings.alpn = [String]()
            self.settings = settings
        case .vless, .trojan, .shadowsocks, .vmess, .ws, .h2:
            let settings = DTTunnelSettings()
            self.settings = settings
            
        default:
            self.proto = proto
        }
    }
    
    func configSetting(model: DTServerDetailData) {
        switch self.proto {
        case .trojan:
            self.settings?.address = model.domain
            self.settings?.password = model.passwd
            self.settings?.port = model.port
        case .vless:
            self.settings?.address = model.domain
            self.settings?.uuid = model.uuid
            self.settings?.port = model.port
        case .vmess:
            self.settings?.address = model.domain
            self.settings?.uuid = model.uuid
            self.settings?.port = model.port
            self.settings?.method = model.algorithm
        default:
            self.settings?.address = model.domain
            self.settings?.password = model.passwd
            self.settings?.port = model.port
        }
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

class DTTunnelSettings: Convertible {
    var address: String?
    var port: Int?
    var uuid: String?
    var method: String?
    var alpn: [String]?
    var serverName: String?
    var actors: [String]?
    var password: String?
    var security: String?
    var path: String?
    var headers: [String: String]?
    var host: String?
    var security_password: String?
    
    required init() {}
}
