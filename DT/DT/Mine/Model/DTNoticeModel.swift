//
//  DTNoticeModel.swift
//  DT
//
//  Created by Ye Keyon on 2021/3/26.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit
import KakaJSON

class DTNoticeModel: DTBaseResult {
    var entry = [DTNoticeItemModel]()
}

class DTNoticeItemModel: Convertible {
    var id: Int = 0
    var title: String = ""
    var content: String = ""
    var pubTime: String = ""
    
    required init() {
        
    }
}
