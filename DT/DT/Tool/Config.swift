//
//  Config.swift
//  DT
//
//  Created by Ye Keyon on 2020/6/30.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

//常用配置
let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

#if DTMain
struct APPColor {
    //主题色
    static let main = UIColor.dt.hex("#1D273C")
    //第二主题色
    static let sub = UIColor.dt.hex("#FFBB00")
    static let color2A506E = UIColor.dt.hex("#2A506E")
    static let color3E5E77 = UIColor.dt.hex("#3E5E77")
    static let color3E617D = UIColor.dt.hex("#3E617D")
    static let colorF6F6F6 = UIColor.dt.hex("#F6F6F6")
    static let colorD8D8D8 = UIColor.dt.hex("#D8D8D8")
    static let color26344F = UIColor.dt.hex("#26344F")
    static let color1B273E = UIColor.dt.hex("#1B273E")
    static let color36BDB8 = UIColor.dt.hex("#36BDB8")
    static let color054369 = UIColor.dt.hex("#054369")
    static let color52AAAA = UIColor.dt.hex("#52AAAA")
    static let color001E36 = UIColor.dt.hex("#001E36")
    static let color00B170 = UIColor.dt.hex("#00B170")
    static let color0D3A57 = UIColor.dt.hex("#0D3A57")
    static let color5C6D79 = UIColor.dt.hex("#5C6D79")
    static let color082138 = UIColor.dt.hex("#082138")
//    static let colorSubBgView = UIColor.white.withAlphaComponent(0.1)
    static let colorSubBgView = UIColor.dt.hex("2B506F")
    static let color26B3AD = UIColor.dt.hex("#26B3AD")
    static let color09598B = UIColor.dt.hex("#09598B")
    static let color235476 = UIColor.dt.hex("#235476")
    static let line = UIColor.dt.hex("#235476")
    static let colorError = UIColor.dt.hex("#F63539")
    //字体颜色
    static let textColorMain = UIColor.dt.hex("#1B273E")
    static let colorWhite = UIColor.white
}
struct APPSystem {
    
    static var kStatusBarHeight: CGFloat {
        var kStatusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            let window = UIApplication.dt.currentWindow()
            kStatusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            kStatusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        return kStatusBarHeight
    }
    
    static let kNaviBarHeight:CGFloat = 44.0
    
    static var kTopLayoutGuideHeight: CGFloat {
        return kNaviBarHeight + kStatusBarHeight
    }
    
    static let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    static let infoDictionary : Dictionary = Bundle.main.infoDictionary!
}

struct DTConstantsKey {
    static let HalfDayKey = "HalfDayKey"
    static let PingHalfDayKey = "PingHalfDayKey"
}


#endif

var baseUrl = "https://api-dev.mytube.vip/"
var downloadUrl = "https://api-dev.mytube.vip/rules/"
//let baseUrl = "https://api.yinli.ga/"
//let downloadUrl = "https://api.yinli.ga/rules/"

let appGroup = "group.com.alphaWisdom.gft"
let DTUserDefaults = UserDefaults(suiteName: appGroup)

let fileManager = FileManager.default
var groupFileManagerURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroup)

let kScreentWidth = UIScreen.main.bounds.width
let kScreentHeight = UIScreen.main.bounds.height

enum API:String {
    case serverList = "lighthouse/server/list"
    case serverConnect = "lighthouse/server/connect"
    case serverDisconnect = "lighthouse/server/disconnect"
    case smsCode = "lighthouse/sms/country_code"
    case validateSend = "lighthouse/sms/validate_code/send"
    case register = "ighthouse/user/register"
    case login = "lighthouse/user/join"
    case modify = "lighthouse/user/passwd/modify"
    case mobileQuery = "lighthouse/user/mobile/query"
    case mobileCheck = "lighthouse/user/mobile/check"
    case codeCheck = "lighthouse/sms/validata_code/check"
    case mobileBind = "lighthouse/user/mobile/bind"
    case messageList = "lighthouse/msg/list"
    case smartConnect = "lighthouse/server/smart/connect"
    case versionCheck = "lighthouse/init/version/check"
    case feedback = "lighthouse/feedback/save"
    case anonymous = "lighthouse/user/anonymous/join"
}

//MARK: -- 常量
let DTUserProfile: String = "DT_User_Profile"
let DTSelectRouter: String = "DTSelectRouter"
let DTSelectProtocolDetail: String = "DTSelectProtocolDetail"
let DTWKURL: String = "url"
let DTWKTitle: String = "title"
let DTProxyModeKey: String = "DT_PROXY_MODE"
let kLaunchScreenVersion: String = "kLaunchScreenVersion"
let kLaunchScreenVersionNumber:Int = 5
//MARK: -- 通知
let LOGOUT_Notification: String = "DT_LOGOUT_Notification"
let PROXY_MODE_CHANGE_Notification: String = "PROXY_MODE_CHANGE_Notification"
