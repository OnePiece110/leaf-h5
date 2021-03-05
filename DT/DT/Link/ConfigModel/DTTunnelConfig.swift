//
//  DTTunnelConfig.swift
//  Tunnel
//
//  Created by Ye Keyon on 2020/12/28.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import KakaJSON

class DTTunnelConfig: Convertible {
    var log: DTTunnelLog = DTTunnelLog()
    var dns: DTTunnelDNS = DTTunnelDNS()
    var inbounds = [DTTunnelInbounds]()
    var outbounds = [DTTunnelOutbounds]()
    var rules = [DTTunnelRule]()
    
    required init() {
        
    }
}
