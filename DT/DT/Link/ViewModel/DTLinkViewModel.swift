//
//  DTLinkViewModel.swift
//  DT
//
//  Created by Ye Keyon on 2020/12/24.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import RxSwift

class DTLinkViewModel {
    
    var serverData = DTServerDetailData()
    
    func connect(id: Int) -> Observable<DTServerDetaiResult> {
        return DTLinkSchedule.connect(id: id).do(onNext: { [weak self] (json) in
            self?.serverData = json.entry
        })
    }
    
    func smartConnect() -> Observable<DTServerDetaiResult> {
        return DTLinkSchedule.smartConnect().do(onNext: { [weak self] (json) in
            self?.serverData = json.entry
        })
    }
    
    func disConnect(id: Int) -> Observable<DTServerDetaiResult> {
        return DTLinkSchedule.disConnect(id: id).do(onNext: { [weak self] (json) in
            self?.serverData = json.entry
        })
    }
    
    func anonymous() -> Observable<DTLoginResult> {
        return DTLinkSchedule.anonymous().do(onNext: { (json) in
            let jsonString = json.entry.kj.JSONString()
            debugPrint(jsonString)
            DTUserDefaults?.set(jsonString, forKey: DTUserProfile)
            DTUserDefaults?.synchronize()
            DTUser.sharedUser.configureData(model: json.entry)
        })
    }
    
}
