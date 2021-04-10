//
//  DTVersionCheckModel.swift
//  DT
//
//  Created by Ye Keyon on 2021/3/27.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit
import KakaJSON

class DTVersionCheckModel: DTBaseResult {
    var entry: DTVersionModel = DTVersionModel()
}

class DTVersionModel: Convertible {
    var version: String = ""
    var forceFlag: Int = 0
    var iosUrl: String = ""
    required init() {
        
    }
}
