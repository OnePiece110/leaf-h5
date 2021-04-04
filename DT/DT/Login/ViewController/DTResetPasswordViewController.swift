//
//  DTResetPasswordViewController.swift
//  DT
//
//  Created by Ye Keyon on 2021/3/23.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit
import RxSwift

class DTResetPasswordViewController: DTBaseViewController, Routable {

    static func initWithParams(params: [String : Any]?) -> UIViewController {
        let vc = DTResetPasswordViewController()
        if let mobile = params?["mobile"] as? String {
            vc.viewModel.mobile = mobile
        }
        if let countryCode = params?["countryCode"] as? String {
            vc.viewModel.countryCode = countryCode
        }
        if let validateCode = params?["validateCode"] as? String {
            vc.viewModel.validateCode = validateCode
        }
        return vc
    }
    
    private var viewModel = DTResetPasswordViewModel()
    private weak var popupView: DTAlertBaseView?
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "忘记密码"
        configSubView()
        phoneTextField.placeholder = "请输入新密码"
    }
    
    @objc func nextButtonClick() {
        let (valid, value) = DTConstants.checkValidText(textField: self.phoneTextField.textField)
        if !valid {
            DTProgress.showError(in: self, message: "请输入密码")
            return
        }
        DTProgress.showProgress(in: self)
        self.viewModel.modify(password: value).subscribe { [weak self] (json) in
            guard let weakSelf = self else { return }
            weakSelf.showPopup()
        } onError: { [weak self] (err) in
            guard let weakSelf = self else { return }
            DTProgress.showError(in: weakSelf, message: "请求失败")
        }.disposed(by: disposeBag)

    }
    
    private func showPopup() {
        let popupView = DTAlertBaseView(frame: .zero)
        popupView.readData(icon: UIImage(named: "icon_login_password"), title: "修改成功", message: "")
        popupView.addGradientAction("请重新登录", titleColor: APPColor.colorWhite, direction: .leftToRight, colors: [APPColor.color36BDB8, APPColor.color00B170], target: self, selector: #selector(popToRoot))
        popupView.finish()
        popupView.alertManager?.show()
        self.popupView = popupView
    }
    
    @objc private func popToRoot() {
        self.popupView?.alertManager?.removeView()
        self.navigationController?.popToRootViewController(animated: true)
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
    private lazy var accountTopView = DTLoginProfileView(title: "新密码")
    private lazy var phoneTextField: DTPaddingTextField = {
        let phoneTextField = DTPaddingTextField(padding: 15)
        phoneTextField.layer.cornerRadius = 10
        phoneTextField.layer.masksToBounds = true
        phoneTextField.textField.isSecureTextEntry = true
        return phoneTextField
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .custom).dt
            .font(UIFont.dt.Font(16))
            .title("确定")
            .titleColor(APPColor.colorWhite)
            .target(add: self, action: #selector(nextButtonClick))
            .build
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        return button
    }()

}
