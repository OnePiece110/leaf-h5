//
//  DTPHAssetsLoadingManager.swift
//  DT
//
//  Created by Ye Keyon on 2021/4/3.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit
import Photos
import RxSwift

class DTPHAssetsLoadingManager {
    static let `default` = DTPHAssetsLoadingManager()
    
    lazy var manager: PHCachingImageManager = {
        let manager = PHCachingImageManager()
        return manager
    }()

    init() {}
    
    func requestImageData(asset: PHAsset) -> Observable<Data> {
        return Observable.create { [weak self] (observer) -> Disposable in
            guard let weakSelf = self else { return Disposables.create() }
            weakSelf.manager.requestImageDataAndOrientation(for: asset, options: nil) { (data, string, orientation, info) in
                if let data = data {
                    observer.onNext(data)
                } else {
                    observer.onError(DTError.StatusFalse)
                }
                observer.onCompleted()
            }
            return Disposables.create {
                debugPrint("requestImageData Disposables")
            }
        }
    }
}
