//
//  DTMineViewModel.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/4.
//  Copyright © 2020 dt. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

enum DTMineRowType {
    case advertisement
    case tool
    case feedback
    case setting
    case question
    case star
    case update
    case logout
}

struct DTMineSectionModel {
    var rowData:[DTMineRowModel]
    var sectionHeight:CGFloat = 0.01
    var sectionFooter:CGFloat = 0.01
}

struct DTMineRowModel {
    var title:String
    var iconName:String
    var descText:String = ""
    var type:DTMineRowType
    var topLeftRadius:CGFloat = 0
    var topRightRadius:CGFloat = 0
    var bottomLeftRadius:CGFloat = 0
    var bottomRightRadius:CGFloat = 0
    var height:CGFloat = 50
}

class DTMineViewModel {
    
    var tableData = [DTMineSectionModel]()
    var updateModel: DTVersionModel = DTVersionModel()
    
    func reloadData() {
        tableData.removeAll()
        
//        var rowDataOne = [DTMineRowModel]()
//        var advertisement = DTMineRowModel(title: "首次成功注册", iconName: "", type: .advertisement)
//        advertisement.descText = "额外赠送2天使用时长"
//        advertisement.height = 62
//        rowDataOne.append(advertisement)
//        let sectionOne = DTMineSectionModel(rowData: rowDataOne)
//        tableData.append(sectionOne)
        
        var rowDataTwo = [DTMineRowModel]()
        var question = DTMineRowModel(title: "常见问题", iconName: "icon_mine_question", type: .question)
        question.topLeftRadius = 10
        question.topRightRadius = 10
        rowDataTwo.append(question)
        var update = DTMineRowModel(title: "检查新版本", iconName: "icon_mine_update", type: .update)
        update.bottomLeftRadius = 10
        update.bottomRightRadius = 10
        rowDataTwo.append(update)
        let sectionTwo = DTMineSectionModel(rowData: rowDataTwo)
        
        var rowDataThree = [DTMineRowModel]()
        var setting = DTMineRowModel(title: "设置", iconName: "icon_mine_setting", type: .setting)
        setting.bottomLeftRadius = 10
        setting.topRightRadius = 10
        setting.topLeftRadius = 10
        setting.bottomRightRadius = 10
        rowDataThree.append(setting)
        var sectionThree = DTMineSectionModel(rowData: rowDataThree)
        sectionThree.sectionHeight = 10
        
        tableData.append(sectionTwo)
        tableData.append(sectionThree)
        
        if DTUser.sharedUser.isLogin {
            var rowDataFour = [DTMineRowModel]()
            var star = DTMineRowModel(title: "评分", iconName: "icon_mine_score", type: .star)
            star.topLeftRadius = 10
            star.topRightRadius = 10
            rowDataFour.append(star)
            var feedback = DTMineRowModel(title: "意见反馈", iconName: "icon_mine_feedback", type: .feedback)
            feedback.bottomLeftRadius = 10
            feedback.bottomRightRadius = 10
            rowDataFour.append(feedback)
            var sectionFour = DTMineSectionModel(rowData: rowDataFour)
            sectionFour.sectionHeight = 10
            
//            var rowDataFive = [DTMineRowModel]()
//            let logOut = DTMineRowModel(title: "退出登录", iconName: "", type: .logout)
//            rowDataFive.append(logOut)
//            var sectionFive = DTMineSectionModel(rowData: rowDataFive)
//            sectionFive.sectionHeight = 50
//            sectionFive.sectionFooter = 20
            
            tableData.append(sectionFour)
//            tableData.append(sectionFive)
        }
    }
    
    func versionCheck() -> Observable<DTVersionCheckModel> {
        return DTMineSchedule.versionCheck().do { [weak self] (json) in
            guard let weakSelf = self else { return }
            weakSelf.updateModel = json.entry
        }
    }
}
