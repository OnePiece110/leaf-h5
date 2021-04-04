//
//  DTLoginSchedule.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/26.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DTLoginSchedule: NSObject {
    
    @discardableResult
    class func country<T: BaseResult>() -> Observable<T> {
        return DTHttp.share.get(url: API.smsCode.rawValue, parameters: nil)
    }
    
    @discardableResult
    class func timer(duration: Int, scheduler: SchedulerType = MainScheduler.instance)
        -> Observable<Int> {
            return Observable<Int>.interval(RxTimeInterval.seconds(1), scheduler: scheduler)
                .map{ duration - $0 }
                .take(while: { $0 > 0 })
    }
    
    @discardableResult
    class func sendCode<T: BaseResult>(mobile:String,countryCode:String) -> Observable<T> {
        var params = [String:Any]()
        params["mobile"] = mobile
        params["countryCode"] = countryCode
        return DTHttp.share.post(url: API.validateSend.rawValue, parameters: params)
    }
    
    class func register<T: BaseResult>(nickName:String?, password:String, mobile:String?, countryCode:String?, validateCode:String?) -> Observable<T> {
        var params = [String:Any]()
        if let nickName = nickName {
            params["nickName"] = nickName
        }
        params["passwd"] = password
        if let mobile = mobile {
            params["mobile"] = mobile
        }
        if let countryCode = countryCode {
            params["countryCode"] = countryCode
        }
        if let validateCode = validateCode {
            params["validateCode"] = validateCode
        }
        return DTHttp.share.post(url: API.register.rawValue, parameters: params)
    }
    
    class func login<T: BaseResult>(password: String?,
                                    mobile: String?,
                                    nickName: String?,
                                    countryCode: String?,
                                    validateCode: String?) -> Observable<T> {
        var params = [String:Any]()
        if let password = password {
            params["passwd"] = password
        }
        if let nickName = nickName {
            params["nickName"] = nickName
        }
        if let mobile = mobile {
            params["mobile"] = mobile
        }
        if let countryCode = countryCode {
            params["countryCode"] = countryCode
        }
        if let validateCode = validateCode {
            params["validateCode"] = validateCode
        }
        return DTHttp.share.post(url: API.login.rawValue, parameters: params)
    }
    
    class func modify<T: BaseResult>(newPasswd:String, mobile:String?, countryCode:String?, validateCode:String?) -> Observable<T> {
        var params = [String:Any]()
        params["newPasswd"] = newPasswd
        if let mobile = mobile {
            params["mobile"] = mobile
        }
        if let countryCode = countryCode {
            params["countryCode"] = countryCode
        }
        if let validateCode = validateCode {
            params["validateCode"] = validateCode
        }
        return DTHttp.share.post(url: API.modify.rawValue, parameters: params)
    }
    
    class func mobileQuery<T: BaseResult>(nickName: String) -> Observable<T> {
        var params = [String:Any]()
        params["nickName"] = nickName
        return DTHttp.share.get(url: API.mobileQuery.rawValue, parameters: params)
    }
    
    class func mobileCheck<T: BaseResult>(nickName: String, mobile: String, countryCode: String) -> Observable<T> {
        var params = [String:Any]()
        params["nickName"] = nickName
        params["mobile"] = mobile
        params["countryCode"] = countryCode
        return DTHttp.share.post(url: API.mobileCheck.rawValue, parameters: params)
    }
    
    class func codeCheck<T: BaseResult>(mobile:String, countryCode:String, validateCode:String) -> Observable<T> {
        var params = [String:Any]()
        params["mobile"] = mobile
        params["validateCode"] = validateCode
        params["countryCode"] = countryCode
        return DTHttp.share.post(url: API.codeCheck.rawValue, parameters: params)
    }
    
    class func mobileBind<T: BaseResult>(mobile:String, countryCode:String, validateCode:String, nickName: String) -> Observable<T> {
        var params = [String:Any]()
        params["mobile"] = mobile
        params["validateCode"] = validateCode
        params["countryCode"] = countryCode
        params["nickName"] = nickName
        return DTHttp.share.post(url: API.mobileBind.rawValue, parameters: params)
    }
    
    class func passwordModify<T: BaseResult>(mobile:String, countryCode:String, validateCode:String) -> Observable<T> {
        var params = [String:Any]()
        params["mobile"] = mobile
        params["validateCode"] = validateCode
        params["countryCode"] = countryCode
        return DTHttp.share.post(url: API.modify.rawValue, parameters: params)
    }
}
