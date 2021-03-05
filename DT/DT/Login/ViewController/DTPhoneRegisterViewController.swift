//
//  DTPhoneRegisterViewController.swift
//  DT
//
//  Created by Ye Keyon on 2021/2/11.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit

class DTPhoneRegisterViewController: DTBaseViewController, Routable {
    
    static func initWithParams(params: [String : Any]?) -> UIViewController {
        let vc = DTPhoneRegisterViewController()
        return vc
    }
    
    private weak var popupView: DTAlertBaseView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "注册"
        configSubView()
        configEvents()
        phoneTextField.placeholder = "请输入手机号"
    }
    
    private func configEvents() {
        nextButton.dt.target(add: self, action: #selector(nextButtonClick))
    }
    
    @objc private func startNetwork() {
        popupView?.alertManager?.dimiss()
    }
    
    @objc func nextButtonClick() {
        Router.routeToClass(DTVerifyCodeViewController.self)
    }
    
    private func configSubView() {
        view.addSubview(accountTopView)
        view.addSubview(phoneTextField)
        view.addSubview(nextButton)
        
        accountTopView.snp.makeConstraints { (make) in
            make.top.equalTo(16)
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
        
        phoneTextField.snp.makeConstraints { (make) in
            make.top.equalTo(accountTopView.snp.bottom).offset(5)
            make.left.right.equalTo(accountTopView)
            make.height.equalTo(50)
        }
        
        nextButton.snp.makeConstraints { (make) in
            make.top.equalTo(phoneTextField.snp.bottom).offset(50)
            make.left.equalTo(22)
            make.right.equalTo(-22)
            make.height.equalTo(50)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nextButton.dt.addGradient(GradientLayer(direction: .leftToRight, colors: [APPColor.color36BDB8, APPColor.color00B170]))
    }
    
    // MARK: -- UI
    private lazy var accountTopView = DTLoginProfileView(title: "手机号")
    private lazy var phoneTextField: DTPaddingTextField = {
        let phoneTextField = DTPaddingTextField(padding: 15)
        phoneTextField.layer.cornerRadius = 10
        phoneTextField.layer.masksToBounds = true
        return phoneTextField
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .custom).dt
            .font(UIFont.dt.Font(16))
            .title("下一步")
            .titleColor(APPColor.colorWhite)
            .build
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        return button
    }()
    
}
