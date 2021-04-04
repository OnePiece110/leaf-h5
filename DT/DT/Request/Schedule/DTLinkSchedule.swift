//
//  DTLinkSchedule.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/25.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import RxSwift

class DTLinkSchedule {
    class func list<T: BaseResult>() -> Observable<T> {
        return DTHttp.share.get(url: API.serverList.rawValue, parameters: nil)
    }
    
    class func connect<T: BaseResult>(id: Int) -> Observable<T> {
        var params = [String:Any]()
        params["id"] = id
        return DTHttp.share.get(url: API.serverConnect.rawValue, parameters: params)
    }
    
    class func disConnect<T: BaseResult>(id: Int) -> Observable<T> {
        var params = [String:Any]()
        params["id"] = id
        return DTHttp.share.get(url: API.serverDisconnect.rawValue, parameters: params)
    }
    
    class func smartConnect<T: BaseResult>() -> Observable<T> {
        return DTHttp.share.get(url: API.smartConnect.rawValue, parameters: nil)
    }
    
    class func messageList<T: BaseResult>(pageNum: Int, pageSize: Int = 20) -> Observable<T> {
        var params = [String:Any]()
        params["pageNum"] = pageNum
        params["pageSize"] = pageSize
        return DTHttp.share.post(url: API.messageList.rawValue, parameters: params)
    }
    
    // 匿名登录
    class func anonymous<T: BaseResult>() -> Observable<T> {
        return DTHttp.share.get(url: API.anonymous.rawValue, parameters: nil)
    }
}
