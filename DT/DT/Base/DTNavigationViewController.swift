//
//  DTNavigationViewController.swift
//  DT
//
//  Created by Ye Keyon on 2020/6/30.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

class DTNavigationViewController: UINavigationController,UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let navigationBar = DTNavigationBar()
        self.setValue(navigationBar, forKey: "navigationBar")
        // *修改导航背景色
        self.navigationBar.barTintColor = APPColor.color054369
        // *修改导航栏文字颜色
        let image = UIImage.dt.imageWithColor(color: APPColor.color054369)
        self.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 16)]
        self.navigationBar.setBackgroundImage(image, for: .default)
        self.navigationBar.shadowImage = UIImage()
        // *修改导航栏按钮颜色
        self.navigationBar.tintColor = .white
        self.navigationBar.backgroundColor = .clear
        self.navigationBar.isTranslucent = false
        self.interactivePopGestureRecognizer?.delegate = self
        self.interactivePopGestureRecognizer?.isEnabled = true
        self.delegate = self
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        // 自定义back按钮
        if viewControllers.count >= 1 {
            let backView = DTBackView(frame: CGRect(x: 0, y: 0, width: 44, height: 44), imageName: "icon_common_back")
            backView.backBtn.addTarget(self, action: #selector(popSelf), for: .touchUpInside)
            let tap = UITapGestureRecognizer(target: self, action: #selector(popSelf))
            backView.addGestureRecognizer(tap)
            backView.isUserInteractionEnabled = true
            let barButtonItem = UIBarButtonItem(customView: backView)
            barButtonItem.style = .done
            viewController.navigationItem.leftBarButtonItems = [barButtonItem]
        }
        super.pushViewController(viewController, animated: animated)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    @objc func popSelf() {
        self.popViewController(animated: true)
    }

}

extension DTNavigationViewController:UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count > 1 {
            self.interactivePopGestureRecognizer?.isEnabled = true
        }else {
            self.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
}
