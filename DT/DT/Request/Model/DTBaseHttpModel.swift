//
//  DTBaseHttpModel.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/25.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import KakaJSON

public typealias BaseResult = BaseCommonResult & Convertible

public protocol BaseCommonResult {
    var isHasNext: Bool? { get }
    var status: Bool? { get }
}

class DTBaseResult:BaseResult {
    var isHasNext: Bool?
    var status: Bool?
    required init() {}
}
