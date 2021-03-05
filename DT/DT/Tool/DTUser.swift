//
//  DTUser.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/26.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import KakaJSON

class DTUser:Convertible {
    
    private(set) var isLogin: Bool = false
    private(set) var accountId: Int = 0
    private(set) var nickName: String = ""
    private(set) var area: String = ""
    private(set) var countryCode: String = ""
    private(set) var mobile: String = ""
    private(set) var token: String = ""
    
    func kj_modelKey(from property: Property) -> ModelPropertyKey {
        switch property.name {
        case "accountId":
            return "id"
        default:
            return property.name
        }
    }
    
    internal static let sharedUser:DTUser = {
        let user = DTUser()
        return user
    }()
    
    required init() {
    }
    
    func configureData(model: DTUser) {
        self.accountId = model.accountId
        self.nickName = model.nickName
        self.countryCode = model.countryCode
        self.mobile = model.mobile
        self.token = model.token
        if self.accountId > 0 {
            self.isLogin = true
        } else {
            self.isLogin = false
        }
    }
    
    private func resetData() {
        self.isLogin = false
        self.accountId = 0
        self.nickName = ""
        self.countryCode = ""
        self.mobile = ""
        self.token = ""
    }
    
    public func clearData() {
        debugPrint("成功退出登录")
        self.resetData()
        
        DTUserDefaults?.set(nil, forKey: DTUserProfile)
        DTUserDefaults?.synchronize()
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: LOGOUT_Notification), object: nil)
        }
    }
}
