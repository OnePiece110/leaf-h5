//
//  DTProgress.swift
//  DT
//
//  Created by Ye Keyon on 2020/12/29.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

class DTProgress {
    
    static func showMessage(in viewController: UIViewController, message:String) {
        viewController.chrysan.changeStatus(to: .plain(message: message))
    }

    static func showProgress(in viewController: UIViewController, message:String = "正在请求") {
        
        let factory = HUDIndicatorFactory.ringIndicator
        
        let responder = HUDResponder()
        responder.register(factory, for: .loading)
        viewController.chrysan.responder = responder
        viewController.chrysan.changeStatus(to: .loading(message: message))

    }
    
    static func dismiss(in viewController: UIViewController) {
        viewController.chrysan.hide()
    }
    
    static func showSuccess(in viewController: UIViewController, message:String = "请求成功") {
        viewController.chrysan.changeStatus(to: .success(message: message))
        viewController.chrysan.hide(afterDelay: 1)
    }
    
    static func showError(in viewController: UIViewController, message:String = "请求失败") {
        viewController.chrysan.changeStatus(to: .failure(message: message))
        viewController.chrysan.hide(afterDelay: 1)
    }
    
}
