//
//  DTMobileQueryViewModel.swift
//  DT
//
//  Created by Ye Keyon on 2021/3/23.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit
import RxSwift

class DTMobileQueryViewModel {
    
    var mobile = ""
    
    func mobileQuery(nickName: String) -> Observable<DTMobileQueryResult> {
        return DTLoginSchedule.mobileQuery(nickName: nickName).do { (json) in
            self.mobile = json.entry
        }
    }
}
