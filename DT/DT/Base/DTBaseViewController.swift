//
//  DTBaseViewController.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/11.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

class DTBaseViewController: UIViewController {

    public var removeSelfAfterDidDisappear = false
    public var removeSelfClassName = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if removeSelfAfterDidDisappear {
            if let viewControllers = self.navigationController?.viewControllers {
                var tempViewControllers = viewControllers
                for (index,viewController) in viewControllers.enumerated() {
                    if viewController.dt.theClassName == removeSelfClassName {
                        tempViewControllers.remove(at: index)
                    }
                }
                self.navigationController?.setViewControllers(tempViewControllers, animated: false)
            }
        }
    }
    
    public func findResultVC(_ vcName:String) -> UIViewController? {
        var resultVC:UIViewController?
        if let viewControllers = self.navigationController?.viewControllers {
            for (_,viewController) in viewControllers.enumerated() {
                if viewController.dt.theClassName == vcName {
                    resultVC = viewController
                    break
                }
            }
        }
        return resultVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.dt.addGradient(GradientLayer(direction: .topToBottom, colors: [APPColor.color054369, APPColor.color082138]))
//        self.view.backgroundColor = APPColor.main
    }
    
    public func popSelf() {
        self.navigationController?.popViewController(animated: true)
    }
    
    public func popResultVC(vcName:String) {
        var result:UIViewController?
        if let navigationController = self.navigationController {
            for vc in navigationController.viewControllers {
                if vc.dt.theClassName == vcName {
                    result = vc
                }
            }
        }
        if let vc = result {
            self.navigationController?.popToViewController(vc, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @discardableResult
    public func addLeftBarButtonItem(imageName:String) -> UIButton {
        let shareBtn = UIButton(type: .custom)
        //icon_share
        shareBtn.setImage(UIImage(named: imageName), for: .normal)
        shareBtn.setImage(UIImage(named: imageName), for: .highlighted)
        shareBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        shareBtn.contentHorizontalAlignment = .left
        let shareItem = UIBarButtonItem(customView: shareBtn)
        self.navigationItem.leftBarButtonItems = [shareItem]
        return shareBtn
    }
    
    @discardableResult
    public func addRightBarButtonItem(imageName:String) -> UIButton {
        let shareBtn = UIButton(type: .custom)
        //icon_share
        shareBtn.setImage(UIImage(named: imageName), for: .normal)
        shareBtn.setImage(UIImage(named: imageName), for: .highlighted)
        shareBtn.sizeToFit()
        let shareItem = UIBarButtonItem(customView: shareBtn)
        self.navigationItem.rightBarButtonItems = [shareItem]
        return shareBtn
    }
    
    @discardableResult
    public func addRightBarButtonItem(rightText:String) -> UIButton {
        let shareBtn = UIButton(type: .custom)
        shareBtn.titleLabel?.font = UIFont.dt.Bold_Font(16)
        //icon_share
        shareBtn.setTitle(rightText, for: .normal)
        shareBtn.setTitle(rightText, for: .highlighted)
        shareBtn.sizeToFit()
        let shareItem = UIBarButtonItem(customView: shareBtn)
        self.navigationItem.rightBarButtonItems = [shareItem]
        return shareBtn
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    deinit {
        debugPrint(self.dt.theClassName + " deinit")
        NotificationCenter.default.removeObserver(self)
    }
}
