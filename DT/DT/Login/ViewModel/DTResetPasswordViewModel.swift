//
//  DTResetPasswordViewModel.swift
//  DT
//
//  Created by Ye Keyon on 2021/3/24.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit
import RxSwift

class DTResetPasswordViewModel: NSObject {
    
    var mobile: String = ""
    var countryCode = "+86"
    var validateCode = ""
    
    func modify(password:String) -> Observable<DTBaseResult> {
        return DTLoginSchedule.modify(newPasswd: password, mobile: self.mobile, countryCode: self.countryCode, validateCode: self.validateCode)
    }
}
