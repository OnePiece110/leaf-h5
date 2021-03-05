//
//  DTSelectCountryViewModel.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/25.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import RxSwift

class DTSelectCountryViewModel {
    
    var dataList = [DTCountryItemModel]()
    
    func getCountry() -> Observable<DTCountryResult> {
        return DTLoginSchedule.country().do(onNext: { [weak self] (json) in
            if let weakSelf = self {
                weakSelf.dataList = json.entry
            }
        })
    }
}
