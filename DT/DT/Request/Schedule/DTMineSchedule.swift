//
//  DTMineSchedule.swift
//  DT
//
//  Created by Ye Keyon on 2021/3/27.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit
import RxSwift

class DTMineSchedule {
    class func versionCheck<T: BaseResult>() -> Observable<T> {
        var param = [String: Any]()
        param["version"] = APPSystem.currentVersion
        return DTHttp.share.get(url: API.versionCheck.rawValue, parameters: param)
    }
    
    class func feedback<T: BaseResult>(imgs: String, feedback: String, contact: String) -> Observable<T> {
        var param = [String: Any]()
        param["imgs"] = imgs
        param["feedback"] = feedback
        param["contact"] = contact
        return DTHttp.share.post(url: API.feedback.rawValue, parameters: param)
    }
}
