//
//  DTDefaultRouteViewModel.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/12.
//  Copyright © 2020 dt. All rights reserved.
//

import Foundation
import UIKit

enum DTViewModeType:String {
    case defualtRoute
    case proxyMode
}

enum DTProxyMode:Int {
    case smart
    case direct
    case proxy
}

class DTDefualtRouteRowModel {
    var title:String
    var descText:String
    var isSelected:Bool
    var topLeftRadius:CGFloat = 0
    var topRightRadius:CGFloat = 0
    var bottomLeftRadius:CGFloat = 0
    var bottomRightRadius:CGFloat = 0
    
    init(title:String, descText:String, isSelected:Bool) {
        self.title = title
        self.descText = descText
        self.isSelected = isSelected
    }
}

class DTDefaultRouteViewModel {
    
    var tableData = [DTDefualtRouteRowModel]()
    
    init(type:DTViewModeType) {
        switch type {
        case .defualtRoute:
            let rowDataOne = DTDefualtRouteRowModel(title: "智能选择线路", descText: "智能选择最合适的高速线路", isSelected: true)
            rowDataOne.topLeftRadius = 10
            rowDataOne.topRightRadius = 10
            tableData.append(rowDataOne)
            
            let rowDataTwo = DTDefualtRouteRowModel(title: "智记住上一次连接", descText: "默认使用上一次连接的线路", isSelected: false)
            rowDataTwo.bottomLeftRadius = 10
            rowDataTwo.bottomRightRadius = 10
            tableData.append(rowDataTwo)
        default:
            var mode = DTProxyMode.smart
            if let modeNum = DTUserDefaults?.integer(forKey: DTProxyModeKey) {
                mode = DTProxyMode(rawValue: modeNum) ?? .smart
            }
            let rowDataOne = DTDefualtRouteRowModel(title: "智能模式(推荐)", descText: "被屏蔽的应用走代理翻墙", isSelected: mode == .smart)
            rowDataOne.topLeftRadius = 10
            rowDataOne.topRightRadius = 10
            tableData.append(rowDataOne)
            
            let rowDataTwo = DTDefualtRouteRowModel(title: "直连模式", descText: "所有应用均不走代理翻墙", isSelected: mode == .direct)
            tableData.append(rowDataTwo)
            
            let rowDataThree = DTDefualtRouteRowModel(title: "全局模式", descText: "所有应用均走代理翻墙", isSelected: mode == .proxy)
            rowDataThree.bottomLeftRadius = 10
            rowDataThree.bottomRightRadius = 10
            tableData.append(rowDataThree)
        }
    }
    
    func reset() {
        for item in self.tableData {
            item.isSelected = false
        }
    }
    
    func changeValue(indexPath: IndexPath) {
        reset()
        self.tableData[indexPath.row].isSelected = true
        DTUserDefaults?.set(indexPath.row, forKey: DTProxyModeKey)
    }
}
