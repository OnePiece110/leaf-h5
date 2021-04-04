//
//  DTVerifyCodeViewModel.swift
//  DT
//
//  Created by Ye Keyon on 2021/3/23.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit
import RxSwift

class DTVerifyCodeViewModel {
    var mobile: String = ""
    var countryCode: String = "+86"
    var nickName: String = ""
    var isCheckSuccess = false
    
    func sendCode(mobile:String, countryCode:String) -> Observable<DTBaseResult> {
        return DTLoginSchedule.sendCode(mobile: mobile, countryCode: countryCode)
    }
    
    func codeCheck(validateCode: String) -> Observable<DTVerifyCodeResult> {
        return DTLoginSchedule.codeCheck(mobile: self.mobile, countryCode: self.countryCode, validateCode: validateCode).do { (json) in
            self.isCheckSuccess = json.entry
        }
    }
}
