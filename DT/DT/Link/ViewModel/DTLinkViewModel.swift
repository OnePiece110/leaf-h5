//
//  DTLinkViewModel.swift
//  DT
//
//  Created by Ye Keyon on 2020/12/24.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import RxSwift

class DTLinkViewModel {
    
    var serverData = DTServerDetailData()
    
    func connect(id: Int) -> Observable<DTServerDetaiResult> {
        return DTLinkSchedule.connect(id: id).do(onNext: { [weak self] (json) in
            self?.serverData = json.entry
        })
    }
    
    
}
