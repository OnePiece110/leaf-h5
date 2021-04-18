//
//  DTFeedbackViewModel.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/28.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import Photos
import RxSwift

enum DTFeedbackType {
    case add
    case image
}

class DTFeedbackModel {
    var image:UIImage?
    var type:DTFeedbackType
    var url = ""
    var asset: PHAsset?
    
    init(image: UIImage?, type: DTFeedbackType, asset: PHAsset?) {
        self.image = image
        self.type = type
        self.asset = asset
    }
    
    init(type: DTFeedbackType, url: String, asset: PHAsset?) {
        self.type = type
        self.url = url
        self.asset = asset
    }
}

class DTFeedbackViewModel {
    
    var dataSource = [DTFeedbackModel]()
    let maxImageCount = 8
    
    init() {
        dataSource.append(DTFeedbackModel(image: nil, type: .add, asset: nil))
    }
    
    func feedback(imgs: String, feedback: String, contact: String) -> Observable<DTBaseResult> {
        return DTMineSchedule.feedback(imgs: imgs, feedback: feedback, contact: contact)
    }
    
}
