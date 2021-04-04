//
//  DTLoginViewModel.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/26.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import RxSwift

class DTLoginViewModel {
    
    func sendCode(mobile:String, countryCode:String) -> Observable<DTBaseResult> {
        return DTLoginSchedule.sendCode(mobile: mobile, countryCode: countryCode)
    }
    
    func login(password: String?,
                     mobile: String?,
                     nickName: String?,
                     countryCode: String?,
                     validateCode: String?) -> Observable<DTLoginResult> {
        return DTLoginSchedule.login(password: password, mobile: mobile, nickName: nickName, countryCode: countryCode, validateCode: validateCode).do(onNext: { (json) in
            let jsonString = json.entry.kj.JSONString()
            debugPrint(jsonString)
            DTUserDefaults?.set(jsonString, forKey: DTUserProfile)
            DTUserDefaults?.synchronize()
            DTUser.sharedUser.configureData(model: json.entry)
        })
    }
}
