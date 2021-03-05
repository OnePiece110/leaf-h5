//
//  DTRouteSelectViewModel.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/18.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import RxSwift

class DTRouteSelectViewModel {
    var normalSectionList = [DTServerGroupData]()
    var vipSectionList = [DTServerGroupData]()
    
    func list() -> Observable<DTServerGroupResult> {
        return DTLinkSchedule.list().do(onNext: { [weak self] (json) in
            let smartSection = DTServerGroupData()
            smartSection.groupName = "智能连接"
            smartSection.groupDescription = "自动为您选择当前最合适您的网络"
            smartSection.groupId = -1
            self?.normalSectionList.append(smartSection)
            self?.normalSectionList.append(contentsOf: json.entry)
        })
    }
    
}
