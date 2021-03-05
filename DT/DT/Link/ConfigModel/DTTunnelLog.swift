//
//  DTTunnelLog.swift
//  Tunnel
//
//  Created by Ye Keyon on 2020/12/28.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import KakaJSON

enum DTLevel:String, ConvertibleEnum {
    case debug
    case trace
    case info
    case warn
    case error
}

class DTTunnelLog: Convertible {
    required init() {}
    
    var level:DTLevel = .debug
    var output:String?
    var outputFile:String?
    init(level: DTLevel) {
        self.level = level
    }
}
