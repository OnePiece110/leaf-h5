//
//  WGToolViewModel.swift
//  WeiGuGlobal
//
//  Created by YeKeyon on 2019/12/4.
//  Copyright © 2019 com.chuang.global. All rights reserved.
//

import UIKit

class DTToolViewModel:NSObject {
    lazy var dataSource:[String] = {
        var dataSource = [String]()
        dataSource.append("切换环境")
        dataSource.append("日志")
//        dataSource.append("Crash")
//        dataSource.append("App Info")
//        dataSource.append("Net")
        return dataSource;
    }()
}
