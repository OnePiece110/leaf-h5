//
//  DTMobileCheckViewModel.swift
//  DT
//
//  Created by Ye Keyon on 2021/3/23.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit
import RxSwift

class DTMobileCheckViewModel {
    
    var nickName: String = ""
    var isCheckSuccess = false
    
    func mobileCheck(mobile: String) -> Observable<DTMobileCheckResult> {
        return DTLoginSchedule.mobileCheck(nickName: self.nickName, mobile: mobile, countryCode: "+86").do { (json) in
            self.isCheckSuccess = json.entry
        }
    }
    
}
