//
//  DTTunnelDNS.swift
//  Tunnel
//
//  Created by Ye Keyon on 2020/12/28.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import KakaJSON

class DTTunnelDNS: Convertible {
    var servers = [String]()
    
    required init() {}
    
    init(servers: [String]) {
        self.servers = servers
    }
}
