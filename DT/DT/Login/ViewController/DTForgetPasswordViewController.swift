//
//  DTForgetPasswordViewController.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/12.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import RxSwift
import KakaJSON

class DTForgetPasswordViewController: DTBaseViewController,Routable {

    static func initWithParams(params: [String: Any]?) -> UIViewController {
        let vc = DTForgetPasswordViewController()
        return vc
    }
    
    var viewModel = DTForgetPasswordViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设置密码"
        configureSubViews()
    }
    
    @objc func forgetPasswordButtonClick() {
        if self.checkValidText(textField: self.accountTextField.textFied) {
            DTProgress.showError(in: self, message: "请填写手机号")
            return
        }
        if self.checkValidText(textField: self.passwordTextField.textFied) {
            DTProgress.showError(in: self, message: "请填写密码")
            return
        }
        if self.checkValidText(textField: self.verifyTextField.textFied) {
            DTProgress.showError(in: self, message: "请填写验证码")
            return
        }
        let mobile = self.getValidText(textField: self.accountTextField.textFied)
        let password = self.getValidText(textField: self.passwordTextField.textFied)
        let validateCode = self.getValidText(textField: self.verifyTextField.textFied)
        self.viewModel.modify(password: password, mobile: mobile, countryCode: self.accountTextField.code, validateCode: validateCode).subscribe(onNext: { [weak self] (json) in
            guard let weakSelf = self else { return }
            DTProgress.showSuccess(in: weakSelf, message: "修改成功")
            weakSelf.popSelf()
        }, onError: { [weak self] (error) in
            guard let weakSelf = self else { return }
            DTProgress.showError(in: weakSelf, message: "请求失败")
        }).disposed(by: disposeBag)
    }
    
    @objc private func finishButtonClick() {
        let logOutView = DTLogOutPopupView.logOutPopup()
        logOutView.titleLabel.textAlignment = .left
        logOutView.titleLabel.text = "你的账号当前已绑定手机号，可以通过短信验证码重置密码。\n是否发送验证码到*********16？"
        logOutView.alertManager?.show()
        logOutView.delegate = self
    }
    
    func checkValidText(textField:UITextField) -> Bool {
        if let text = textField.text, !text.isVaildEmpty() {
            return true
        }
        return false
    }
    
    func getValidText(textField:UITextField) -> String {
        guard let text = textField.text else {
            return ""
        }
        return text
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        finishButton.dt.addGradient(GradientLayer(direction: .leftToRight, colors: [APPColor.color36BDB8, APPColor.color00B170]))
    }
    
    func configureSubViews() {
        self.view.addSubview(bgView)
        bgView.addSubview(accountTextField)
        bgView.addSubview(oldPasswordTextField)
        bgView.addSubview(newPasswordTextField)
        bgView.addSubview(checkPasswordTextField)
        accountTextField.radiusView.backgroundColor = .clear
        oldPasswordTextField.radiusView.backgroundColor = .clear
        newPasswordTextField.radiusView.backgroundColor = .clear
        checkPasswordTextField.radiusView.backgroundColor = .clear
        self.view.addSubview(descLabel)
        self.view.addSubview(forgetOldPasswordButton)
        self.view.addSubview(finishButton)
        
        bgView.snp.makeConstraints { (make) in
            make.left.top.equalTo(10)
            make.right.equalTo(-10)
        }
        
        accountTextField.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(50)
        }
        
        oldPasswordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(accountTextField.snp.bottom)
            make.left.right.equalTo(0)
            make.height.equalTo(50)
        }
        
        newPasswordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(oldPasswordTextField.snp.bottom)
            make.left.right.equalTo(0)
            make.height.equalTo(50)
        }
        
        checkPasswordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(newPasswordTextField.snp.bottom)
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(50)
        }
        
        descLabel.snp.makeConstraints { (make) in
            make.left.equalTo(25)
            make.right.equalTo(-25)
            make.top.equalTo(bgView.snp.bottom).offset(10)
        }
        
        forgetOldPasswordButton.snp.makeConstraints { (make) in
            make.left.equalTo(descLabel)
            make.top.equalTo(descLabel.snp.bottom)
            make.height.equalTo(20)
        }
        
        finishButton.snp.makeConstraints { (make) in
            make.top.equalTo(forgetOldPasswordButton.snp.bottom).offset(50)
            make.left.equalTo(22)
            make.right.equalTo(-22)
            make.height.equalTo(50)
        }
    }
    
    private lazy var bgView: UIView = {
        let bgView = UIView().dt.backgroundColor(APPColor.colorSubBgView).build
        bgView.layer.cornerRadius = 10
        bgView.layer.masksToBounds = true
        return bgView
    }()
    
    private lazy var accountTextField: DTTextFieldView = {
        let accountTextField = DTTextFieldView(code: "账号/用户名", placeHolder: "请输入账号/用户名", corner: 0)
        accountTextField.delegate = self
        return accountTextField
    }()
    private lazy var oldPasswordTextField = DTTextFieldView(code: "原密码", placeHolder: "请填写原密码", corner: 0)
    private lazy var newPasswordTextField = DTTextFieldView(code: "新密码", placeHolder: "请填写新密码", corner: 0)
    private lazy var checkPasswordTextField = DTTextFieldView(code: "确认密码", placeHolder: "请再次输入新密码", corner: 0)
    private lazy var descLabel: UILabel = {
        let descLabel = UILabel().dt
            .font(UIFont.dt.Bold_Font(14))
            .textColor(APPColor.colorWhite.withAlphaComponent(0.3))
            .text("密码必须是6-20位的数字、字符组合(不能是纯数字)字母区分大小写")
            .numberOfLines(0)
            .build
        return descLabel
    }()
    private lazy var forgetOldPasswordButton: UIButton = {
        let forgetOldPasswordButton = UIButton(type: .custom).dt
            .title("忘记原密码？")
            .titleColor(APPColor.color36BDB8)
            .font(UIFont.dt.Bold_Font(14))
            .build
        return forgetOldPasswordButton
    }()
    lazy var passwordTextField = DTTextFieldView(iconName: "icon_login_password", placeHolder: "请输入密码", isSecureTextEntry: true)
    lazy var verifyTopView = DTLoginProfileView(title: "验证码")
    lazy var verifyTextField:DTCutDownTextField = {
        let verifyTextField = DTCutDownTextField(iconName: "icon_login_verify_phone", placeHolder: "请输入手机验证码")
        verifyTextField.delegate = self
        return verifyTextField
    }()
    
    lazy var finishButton:UIButton = {
        let finishButton = UIButton(type: .custom).dt
            .font(UIFont.dt.Bold_Font(16))
            .title("完成")
            .titleColor(APPColor.colorWhite)
            .target(add: self, action: #selector(finishButtonClick))
            .build
        finishButton.layer.cornerRadius = 25
        finishButton.layer.masksToBounds = true
        return finishButton
    }()

}

extension DTForgetPasswordViewController: DTTextFieldViewDelegate {
    func selectCountryClick() {
        Router.routeToClass(DTSelectCountryViewController.self, params: ["delegate":self])
    }
}

extension DTForgetPasswordViewController: DTSelectCountryViewControllerDelegate {
    func countrySelect(vc: DTSelectCountryViewController, model: DTCountryItemModel) {
        self.accountTextField.code = model.areaCode
    }
}

extension DTForgetPasswordViewController: DTCutDownTextFieldDelegate {
    func countDownClick() {
        if !self.checkValidText(textField: self.accountTextField.textFied) {
            DTProgress.showError(in: self, message: "请输入手机号")
            return
        }
        let mobile = self.getValidText(textField: self.accountTextField.textFied)
        DTProgress.showProgress(in: self)
        self.viewModel.sendCode(mobile: mobile, countryCode: self.accountTextField.code).subscribe(onNext: { [weak self] (json) in
            guard let weakSelf = self else { return }
            DTProgress.showSuccess(in: weakSelf, message: "请求成功")
            weakSelf.verifyTextField.startCutDownAction()
        }, onError: { [weak self] (error) in
            guard let weakSelf = self else { return }
            DTProgress.showError(in: weakSelf, message: "请求失败")
        }).disposed(by: disposeBag)
    }
}

extension DTForgetPasswordViewController: DTLogOutPopupViewDelegate {
    func sureButtonClick() {
        
    }
    
    func cancelButtonClick() {
        
    }
}
