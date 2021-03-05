//
//  DTCountryModel.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/25.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import KakaJSON

class DTCountryResult: DTBaseResult {
    var entry = [DTCountryItemModel]()
}

class DTCountryItemModel:Convertible {
    var logo: String = ""
    var name: String = ""
    var code: String = ""
    var areaCode: String = ""
    var serverCode: String = ""
    
    required init() {
    }
    
}
