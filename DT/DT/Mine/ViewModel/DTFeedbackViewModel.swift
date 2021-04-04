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
    var asset: PHAsset?
    var requestId: PHImageRequestID?
    var type:DTFeedbackType
    var url = ""
    
    init(image: UIImage?, type: DTFeedbackType) {
        self.image = image
        self.type = type
    }
    
    init(type: DTFeedbackType, url: String) {
        self.type = type
        self.url = url
    }
}

class DTFeedbackViewModel {
    
    var dataSource = [DTFeedbackModel]()
    let maxImageCount = 9
    
    init() {
        dataSource.append(DTFeedbackModel(image: nil, type: .add))
    }
    
    func feedback(imgs: String, feedback: String) -> Observable<DTBaseResult> {
        return DTMineSchedule.feedback(imgs: imgs, feedback: feedback)
    }
    
}
