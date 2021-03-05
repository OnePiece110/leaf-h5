//
//  DTUserProfileViewModel.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/12.
//  Copyright © 2020 dt. All rights reserved.
//

import Foundation
import UIKit

enum DTUserProfileRowType {
    case bindInvite
    case device
    case phone
    case email
    case password
    case logout
    case avatar
    case username
}

struct DTUserProfileSectionModel {
    var rowData:[DTUserProfileRowModel]
    var sectionHeight:CGFloat = 13
}

struct DTUserProfileRowModel {
    var title:String
    var descText:String = ""
    var attributeStr:NSAttributedString?
    var type:DTUserProfileRowType
    var topLeftRadius:CGFloat = 0
    var topRightRadius:CGFloat = 0
    var bottomLeftRadius:CGFloat = 0
    var bottomRightRadius:CGFloat = 0
    var corner:CGFloat = 0
    var path = ""
    var buttonText = ""
    var height:CGFloat = 50
}

class DTUserProfileViewModel {
    
    var tableData = [DTUserProfileSectionModel]()
    
    init() {
//        var rowDataOne = [DTUserProfileRowModel]()
//        var bindInvite = DTUserProfileRowModel(title: "绑定邀请码", type: .bindInvite)
//        bindInvite.descText = "未绑定"
//        bindInvite.corner = 10
//        rowDataOne.append(bindInvite)
//        var sectionOne = DTUserProfileSectionModel(rowData: rowDataOne)
//        sectionOne.sectionHeight = 0.01
        
        var rowDataTwo = [DTUserProfileRowModel]()
        
        var avatar = DTUserProfileRowModel(title: "头像", type: .avatar)
        avatar.topLeftRadius = 10
        avatar.topRightRadius = 10
        avatar.height = 70
        rowDataTwo.append(avatar)
        
        var username = DTUserProfileRowModel(title: "用户名", type: .username)
        username.descText = DTUser.sharedUser.nickName
        username.bottomLeftRadius = 10
        username.bottomRightRadius = 10
        rowDataTwo.append(username)
        
        let sectionTwo = DTUserProfileSectionModel(rowData: rowDataTwo)
        
        var rowDataThree = [DTUserProfileRowModel]()
        var bindInvite = DTUserProfileRowModel(title: "绑定手机号", type: .bindInvite)
        bindInvite.topLeftRadius = 10
        bindInvite.topRightRadius = 10
        bindInvite.buttonText = "首次绑定送时长"
        rowDataThree.append(bindInvite)
        
        var password = DTUserProfileRowModel(title: "设置密码", type: .password)
        password.bottomLeftRadius = 10
        password.bottomRightRadius = 10
        rowDataThree.append(password)
        
        var sectionThree = DTUserProfileSectionModel(rowData: rowDataThree)
        sectionThree.sectionHeight = 10
        
//        tableData.append(sectionOne)
        tableData.append(sectionTwo)
        tableData.append(sectionThree)
    }
    
    func createAttributeMain(_ string:String) -> NSAttributedString {
        let font = UIFont.dt.Bold_Font(16)
        return string.font(font).color(UIColor.white.withAlphaComponent(0.3))
    }
    
    func createAttributeSub(_ string:String) -> NSAttributedString {
        let font = UIFont.dt.Bold_Font(14)
        return string.font(font).color(APPColor.sub)
    }
}
