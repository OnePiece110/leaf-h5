//
//  DTUpdateUserNameViewController.swift
//  DT
//
//  Created by Ye Keyon on 2021/2/12.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit

class DTUpdateUserNameViewController: DTBaseViewController, Routable {

    static func initWithParams(params: [String : Any]?) -> UIViewController {
        let vc = DTUpdateUserNameViewController()
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "修改用户名"
        configSubViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nextButton.dt.addGradient(GradientLayer(direction: .leftToRight, colors: [APPColor.color36BDB8, APPColor.color00B170]))
    }
    
    private func configSubViews() {
        view.addSubview(usernameTextField)
        view.addSubview(descLabel)
        view.addSubview(nextButton)
        
        usernameTextField.snp.makeConstraints { (make) in
            make.left.top.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(50)
        }
        
        descLabel.snp.makeConstraints { (make) in
            make.left.equalTo(usernameTextField)
            make.top.equalTo(usernameTextField.snp.bottom).offset(10)
            make.height.equalTo(20)
        }
        
        nextButton.snp.makeConstraints { (make) in
            make.top.equalTo(descLabel.snp.bottom).offset(50)
            make.left.equalTo(22)
            make.right.equalTo(-22)
            make.height.equalTo(50)
        }
    }
    
    // MARK: -- UI
    private lazy var usernameTextField: DTPaddingTextField = {
        let usernameTextField = DTPaddingTextField(padding: 15)
        usernameTextField.layer.cornerRadius = 10
        usernameTextField.layer.masksToBounds = true
        usernameTextField.placeholder = "请输入用户名"
        return usernameTextField
    }()
    
    private lazy var descLabel: UILabel = {
        let descLabel = UILabel().dt
            .font(UIFont.dt.Bold_Font(14))
            .text("用户名可在登录时使用")
            .textColor(APPColor.colorWhite.withAlphaComponent(0.3))
            .build
        return descLabel
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .custom).dt
            .font(UIFont.dt.Font(16))
            .title("完成")
            .titleColor(APPColor.colorWhite)
            .build
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        return button
    }()
}
