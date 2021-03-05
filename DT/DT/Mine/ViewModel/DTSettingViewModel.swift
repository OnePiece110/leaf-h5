//
//  DTSettingViewModel.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/11.
//  Copyright © 2020 dt. All rights reserved.
//

import Foundation
import UIKit

enum SettingType:Int {
    case proxyMode
    case lineSetting
    case privacyPolicy
    case serverTerms
}

struct DTSettingSectionModel {
    var rowData:[DTSettingRowModel]
    var sectionHeight:CGFloat = 0.01
    var sectionFooter:CGFloat = 0.01
}

struct DTSettingRowModel {
    var title:String
    var descText:String
    var type:SettingType
    var topLeftRadius:CGFloat = 0
    var topRightRadius:CGFloat = 0
    var bottomLeftRadius:CGFloat = 0
    var bottomRightRadius:CGFloat = 0
}

class DTSettingViewModel {
    
    var tableData = [DTSettingSectionModel]()
    
    init() {
        var rowDataOne = [DTSettingRowModel]()
        var rowModelOne = DTSettingRowModel(title: "代理模式", descText: "智能模式(推荐)", type: .proxyMode)
        rowModelOne.topLeftRadius = 10
        rowModelOne.topRightRadius = 10
        rowDataOne.append(rowModelOne)
        var rowModelTwo = DTSettingRowModel(title: "默认线路设置", descText: "智能选择线路", type: .lineSetting)
        rowModelTwo.bottomLeftRadius = 10
        rowModelTwo.bottomRightRadius = 10
        rowDataOne.append(rowModelTwo)
        var sectionOne = DTSettingSectionModel(rowData: rowDataOne)
        sectionOne.sectionFooter = 10
        
        var rowDataTwo = [DTSettingRowModel]()
        var rowDataTwoOfOne = DTSettingRowModel(title: "隐私政策", descText: "", type: .privacyPolicy)
        rowDataTwoOfOne.topLeftRadius = 10
        rowDataTwoOfOne.topRightRadius = 10
        rowDataTwo.append(rowDataTwoOfOne)
        var rowDataTwoOfTwo = DTSettingRowModel(title: "服务条款", descText: "", type: .serverTerms)
        rowDataTwoOfTwo.bottomLeftRadius = 10
        rowDataTwoOfTwo.bottomRightRadius = 10
        rowDataTwo.append(rowDataTwoOfTwo)
        let sectionTwo = DTSettingSectionModel(rowData: rowDataTwo)
        
        tableData.append(sectionOne)
        tableData.append(sectionTwo)
    }
}
