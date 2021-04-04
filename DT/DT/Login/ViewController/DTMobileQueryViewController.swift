//
//  DTMobileQueryViewController.swift
//  DT
//
//  Created by Ye Keyon on 2021/3/23.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit
import RxSwift

class DTMobileQueryViewController: DTBaseViewController, Routable {

    static func initWithParams(params: [String : Any]?) -> UIViewController {
        let vc = DTMobileQueryViewController()
        return vc
    }
    
    private var viewModel = DTMobileQueryViewModel()
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "忘记密码"
        configSubView()
        phoneTextField.placeholder = "请输入用户名"
    }
    
    @objc func nextButtonClick() {
        let (isValid, nickName) = DTConstants.checkValidText(textField: self.phoneTextField.textField)
        if !isValid {
            DTProgress.showError(in: self, message: "请输入用户名")
            return
        }
        DTProgress.showProgress(in: self)
        self.viewModel.mobileQuery(nickName: nickName).subscribe { [weak self] (json) in
            guard let weakSelf = self else { return }
            DTProgress.dismiss(in: weakSelf)
            let mobile = weakSelf.viewModel.mobile
            if mobile.isVaildEmpty() {
                Router.routeToClass(DTAddPhoneViewController.self, params: ["nickName": nickName])
            } else {
                Router.routeToClass(DTMobileCheckViewController.self, params: ["nickName": nickName, "mobile": weakSelf.viewModel.mobile])
            }
            
        } onError: { [weak self] (error) in
            guard let weakSelf = self else { return }
            DTProgress.showError(in: weakSelf, message: "请求失败")
        }.disposed(by: disposeBag)

//        self.viewModel.mo
        
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
    private lazy var accountTopView = DTLoginProfileView(title: "用户名")
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
            .target(add: self, action: #selector(nextButtonClick))
            .build
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        return button
    }()

}
