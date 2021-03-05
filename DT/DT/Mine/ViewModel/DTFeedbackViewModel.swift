//
//  DTFeedbackViewModel.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/28.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

enum DTFeedbackType {
    case add
    case image
}

class DTFeedbackModel {
    var image:UIImage?
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
    
}
