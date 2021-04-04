//
//  DTLoginViewController.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/12.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import RxSwift
import KakaJSON

struct DTLoginVCParam: Convertible {
    var isAddNavigation = false
}

class DTLoginViewController: DTBaseViewController,Routable {

    static func initWithParams(params: [String: Any]?) -> UIViewController {
        let vc = DTLoginViewController()
        let resultVC:UIViewController!
        if let params = params {
            let json = params.kj.model(DTLoginVCParam.self)
            if json.isAddNavigation {
                resultVC = DTNavigationViewController(rootViewController: vc)
                resultVC.modalPresentationStyle = .fullScreen
            } else {
                resultVC = vc
            }
        } else {
            resultVC = vc
        }
        return resultVC
    }
    
    let disposeBag = DisposeBag()
    var viewModel = DTLoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let closeButton = addLeftBarButtonItem(imageName: "icon_common_close")
        closeButton.addTarget(self, action: #selector(closeClick), for: .touchUpInside)
        configureSubViews()
        accountLoginButtonClick(sender: self.accountLoginButton)
    }
    
    @objc func closeClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func forgetAccountClick() {
        Router.routeToClass(DTMobileQueryViewController.self, params: nil)
    }
    
    @objc func accountLoginButtonClick(sender: UIButton) {
        accountTextField.textFied.placeholder = "用户名/手机号"
        accountTopView.title = "账号"
        passwordTopView.title = "密码"
        passwordTextField.isHidden = false;
        codeTextField.isHidden = true
        forgetAccountButton.isHidden = false
        noSecretButton.isSelected = false
        accountLoginButton.isSelected = true
    }
    
    @objc func noSecretButtonClick(sender: UIButton) {
        accountTextField.textFied.placeholder = "请输入手机号"
        accountTopView.title = "手机号"
        passwordTopView.title = "验证码"
        passwordTextField.isHidden = true
        codeTextField.isHidden = false
        forgetAccountButton.isHidden = true
        noSecretButton.isSelected = true
        accountLoginButton.isSelected = false
    }
    
    @objc func loginClick() {
        if noSecretButton.isSelected {
            self.loginPhone()
        } else {
            self.loginAccount()
        }
    }
    
    private func loginAccount() {
        if !self.checkValidText(textField: self.accountTextField.textFied) {
            DTProgress.showError(in: self, message: "请输入手机号")
            return
        }
        if !self.checkValidText(textField: self.passwordTextField.textFied) {
            DTProgress.showError(in: self, message: "请输入密码")
            return
        }
        let account = self.getValidText(textField: self.accountTextField.textFied)
        let password = self.getValidText(textField: self.passwordTextField.textFied)
        DTProgress.showProgress(in: self)
        self.viewModel.login(password: password, mobile: nil, nickName: account, countryCode: nil, validateCode: nil).subscribe { [weak self] (json) in
            guard let weakSelf = self else { return }
            DTProgress.showSuccess(in: weakSelf, message: "登录成功")
            weakSelf.dismiss(animated: true, completion: nil)
        } onError: { [weak self] (error) in
            guard let weakSelf = self else { return }
            DTProgress.showError(in: weakSelf, message: "请求失败")
        }.disposed(by: disposeBag)
    }
    
    private func loginPhone() {
        if !self.checkValidText(textField: self.accountTextField.textFied) {
            DTProgress.showError(in: self, message: "请输入手机号")
            return
        }
        if !self.checkValidText(textField: self.codeTextField.textFied) {
            DTProgress.showError(in: self, message: "请输入密码")
            return
        }
        let mobile = self.getValidText(textField: self.accountTextField.textFied)
        let code = self.getValidText(textField: self.codeTextField.textFied)
        DTProgress.showProgress(in: self)
        // countryCode暂时写死
        self.viewModel.login(password: nil, mobile: mobile, nickName: nil, countryCode: "+86", validateCode: code).subscribe { [weak self] (json) in
            guard let weakSelf = self else { return }
            DTProgress.showSuccess(in: weakSelf, message: "登录成功")
            weakSelf.dismiss(animated: true, completion: nil)
        } onError: { [weak self] (error) in
            guard let weakSelf = self else { return }
            DTProgress.showError(in: weakSelf, message: "请求失败")
        }.disposed(by: disposeBag)
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
        loginButton.dt.addGradient(GradientLayer(direction: .leftToRight, colors: [APPColor.color36BDB8, APPColor.color00B170]))
    }
    
    func configureSubViews() {
        self.view.addSubview(bgView)
        bgView.addSubview(accountLoginButton)
        bgView.addSubview(noSecretButton)
        bgView.addSubview(accountTopView)
        bgView.addSubview(accountTextField)
        bgView.addSubview(passwordTopView)
        bgView.addSubview(passwordTextField)
        bgView.addSubview(codeTextField)
        bgView.addSubview(forgetAccountButton)
        self.view.addSubview(loginButton)
        
        bgView.snp.makeConstraints { (make) in
            make.top.left.equalTo(10)
            make.right.equalTo(-10)
        }
        
        accountLoginButton.snp.makeConstraints { (make) in
            make.height.equalTo(48)
            make.top.left.equalTo(0)
        }
        
        noSecretButton.snp.makeConstraints { (make) in
            make.top.right.equalTo(0)
            make.left.equalTo(accountLoginButton.snp.right)
            make.height.width.equalTo(accountLoginButton)
        }
        
        accountTopView.snp.makeConstraints { (make) in
            make.top.equalTo(self.accountLoginButton.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
        
        accountTextField.snp.makeConstraints { (make) in
            make.top.equalTo(accountTopView.snp.bottom).offset(5)
            make.left.right.equalTo(accountTopView)
            make.height.equalTo(44)
        }
        
        passwordTopView.snp.makeConstraints { (make) in
            make.top.equalTo(accountTextField.snp.bottom).offset(10)
            make.left.right.equalTo(accountTextField)
        }
        
        passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(passwordTopView.snp.bottom).offset(6)
            make.left.right.equalTo(passwordTopView)
            make.height.equalTo(44)
        }
        
        codeTextField.snp.makeConstraints { (make) in
            make.top.equalTo(passwordTopView.snp.bottom).offset(6)
            make.left.right.equalTo(passwordTopView)
            make.height.equalTo(44)
        }
        
        forgetAccountButton.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.bottom.equalTo(-10)
            make.top.equalTo(passwordTextField.snp.bottom).offset(10)
            make.height.equalTo(20)
        }
        
        loginButton.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.left.right.equalTo(bgView)
            make.top.equalTo(bgView.snp.bottom).offset(50)
        }
        
    }
    
    //MARK: -- UI
    private lazy var bgView: UIView = {
        let bgView = UIView().dt
            .backgroundColor(APPColor.color2A506E)
            .build
        bgView.layer.cornerRadius = 10
        bgView.layer.masksToBounds = true
        return bgView
    }()
    
    private lazy var accountLoginButton: UIButton = {
        let button = UIButton(type: .custom).dt
            .title("账号登录")
            .background(UIImage.dt.imageWithColor(color: .clear), for: .selected)
            .background(UIImage.dt.imageWithColor(color: APPColor.color3E617D), for: .normal)
            .font(UIFont.dt.Bold_Font(16))
            .target(add: self, action: #selector(accountLoginButtonClick(sender:)))
            .isSelected(true)
            .build
        return button
    }()
    
    private lazy var noSecretButton: UIButton = {
        let button = UIButton(type: .custom).dt
            .title("免密登录")
            .background(UIImage.dt.imageWithColor(color: .clear), for: .selected)
            .background(UIImage.dt.imageWithColor(color: APPColor.color3E617D), for: .normal)
            .font(UIFont.dt.Bold_Font(16))
            .target(add: self, action: #selector(noSecretButtonClick(sender:)))
            .build
        return button
    }()
    
    private lazy var forgetAccountButton:UIButton = {
        let forgetAccountButton = UIButton(type: .custom).dt
            .title("忘记密码？")
            .font(UIFont.dt.Font(14))
            .titleColor(APPColor.color36BDB8)
            .target(add: self, action: #selector(forgetAccountClick))
            .build
        return forgetAccountButton
    }()
    
    private lazy var loginButton:UIButton = {
        let loginButton = UIButton(type: .custom).dt
            .title("登录/注册")
            .font(UIFont.dt.Bold_Font(16))
            .titleColor(APPColor.colorWhite)
            .target(add: self, action: #selector(loginClick))
            .build
        loginButton.layer.cornerRadius = 25
        loginButton.layer.masksToBounds = true
        return loginButton
    }()
    
    private lazy var accountTopView = DTLoginProfileView(title: "账号")
    private lazy var accountTextField: DTTextFieldView = {
        let accountTextField = DTTextFieldView(iconName: "icon_login_password", placeHolder: "用户名/手机号")
        accountTextField.delegate = self
        return accountTextField
    }()
    private lazy var passwordTopView = DTLoginProfileView(title: "密码")
    private lazy var passwordTextField = DTTextFieldView(iconName: "icon_login_password", placeHolder: "请输入密码", isSecureTextEntry: true)
    private lazy var codeTextField: DTCutDownTextField = {
        let codeTextField = DTCutDownTextField(iconName: "icon_login_verify_code", placeHolder: "请输入验证码")
        codeTextField.delegate = self
        return codeTextField
    }()

}

extension DTLoginViewController: DTTextFieldViewDelegate {
    func selectCountryClick() {
        Router.routeToClass(DTSelectCountryViewController.self, params: ["delegate":self])
    }
}

extension DTLoginViewController: DTSelectCountryViewControllerDelegate {
    func countrySelect(vc: DTSelectCountryViewController, model: DTCountryItemModel) {
        self.accountTextField.code = model.areaCode
    }
}

extension DTLoginViewController: DTCutDownTextFieldDelegate {
    func countDownClick() {
        if !self.checkValidText(textField: self.accountTextField.textFied) {
            DTProgress.showError(in: self, message: "请输入手机号")
            return
        }
        let mobile = self.getValidText(textField: self.accountTextField.textFied)
        self.viewModel.sendCode(mobile: mobile, countryCode: "+86").subscribe(onNext: { [weak self] (json) in
            guard let weakSelf = self else { return }
            DTProgress.showSuccess(in: weakSelf, message: "请求成功")
            weakSelf.codeTextField.startCutDownAction()
        }, onError: { [weak self] (error) in
            guard let weakSelf = self else { return }
            DTProgress.showError(in: weakSelf, message: "请求失败")
        }).disposed(by: disposeBag)

    }
}
