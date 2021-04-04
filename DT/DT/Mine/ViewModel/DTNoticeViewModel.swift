//
//  DTNoticeViewModel.swift
//  DT
//
//  Created by Ye Keyon on 2021/3/26.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit
import RxSwift

class DTNoticeViewModel {
    
    private var pageNum = 1
    var dataSource = [DTNoticeItemModel]()
    
    func refresh() -> Observable<DTNoticeModel> {
        pageNum = 0
        return self.list()
    }
    
    func loadMore() -> Observable<DTNoticeModel> {
        pageNum += 1
        return self.list()
    }
    
    private func list() -> Observable<DTNoticeModel> {
        return DTLinkSchedule.messageList(pageNum: pageNum).do(onNext: { [weak self] (json) in
            guard let weakSelf = self else { return }
            if weakSelf.pageNum == 0 {
                weakSelf.dataSource = json.entry
            } else {
                weakSelf.dataSource.append(contentsOf: json.entry)
            }
        })
    }
}
