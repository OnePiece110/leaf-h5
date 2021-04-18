//
//  DTLineTool.swift
//  DT
//
//  Created by Ye Keyon on 2021/4/18.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit
import RxSwift

class DTLineTool: NSObject {
    
    var normalSectionList = [DTServerGroupData]()
    
    internal static let shared: DTLineTool = {
        let lineTool = DTLineTool()
        return lineTool
    }()
    
    private let disposeBag = DisposeBag()
    private let isFirst: Int = 0
    private let endTime: Int = 0
    
    func requestData(vc: UIViewController?, completeBlock: (() -> Void)?, reloadBlock: (() -> Void)?) {
        reset()
        if self.normalSectionList.count == 0, let vc = vc {
            DTProgress.showProgress(in: vc)
        }
        
        DTLinkSchedule.list().subscribe { [weak self] (json: DTServerGroupResult) in
            let smartSection = DTServerGroupData()
            smartSection.groupName = "智能连接"
            smartSection.groupDescription = "自动为您选择当前最合适您的网络"
            smartSection.groupId = -1
            var list = [DTServerGroupData]()
            list.append(smartSection)
            list.append(contentsOf: json.entry)
            if let vc = vc {
                DTProgress.dismiss(in: vc)
            }
            self?.normalSectionList = list
            completeBlock?()
            self?.pingAllDomain(reloadBlock: reloadBlock)
        } onError: { (err) in
            if let vc = vc {
                DTProgress.dismiss(in: vc)
            }
            completeBlock?()
        }.disposed(by: disposeBag)
    }
    
    private func reset() {
        for item in self.normalSectionList {
            item.isOpen = false
        }
    }
    
//    private func getIPs() -> [String] {
//        var ips = [String]()
//        for group in self.normalSectionList {
//            for item in group.serverVOList {
//                ips.append(item.domain)
//            }
//        }
//    }
    
    private func pingAllDomain(reloadBlock: (() -> Void)?) {
        var pingObsebables = [Observable<Double>]()
        var pingResultCount = 0
        for group in self.normalSectionList {
            for item in group.serverVOList {
                let observer = self.pingRow(model: item).do { (ping) in
                    item.ping = ping
                    pingResultCount += 1
                    if pingResultCount % 4 == 0 {
                        reloadBlock?()
                    }
                } onError: { (err) in
                    debugPrint(err)
                }
                pingObsebables.append(observer)
            }
        }
        Observable.concat(pingObsebables).subscribe(on: SerialDispatchQueueScheduler(internalSerialQueueName: "dt.group.ping")).map{ $0 }.toArray().subscribe { (pingDatas) in
            reloadBlock?()
        } onFailure: { (err) in
            print(err)
        }.disposed(by: disposeBag)

    }
    
    private func pingRow(model: DTServerVOItemData) -> Observable<Double> {
        return Observable<Double>.create { (observer) -> Disposable in
            let ping = SwiftyPing(configuration: PingConfiguration(interval: 1.0, with: 1), queue: DispatchQueue.global())
            ping.targetCount = 1
            ping.observer = { (response) in
                observer.onNext(response.duration! * 1000)
                observer.onCompleted()
            }
            ping.startPing(host: model.domain)
            return Disposables.create {
                
            }
        }
    }
    
}
