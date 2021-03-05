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
}
