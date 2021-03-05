//
//  DTCreateAccountViewController.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/12.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import RxSwift

enum createAccountType:String {
    case phone
    case email
}

class DTCreateAccountViewController: DTBaseViewController,Routable {

    static func initWithParams(params: [String: Any]?) -> UIViewController {
        let vc = DTCreateAccountViewController()
        return vc
    }
    
    let disposeBag = DisposeBag()
    let viewModel = DTCreateAccountViewModel()
    
    var type:createAccountType = .phone {
        didSet {
            if type == .phone {
                self.titleLabel.text = "手机注册"
                self.accountTopView.title = "手机号"
                self.accountTextField.code = "+86"
            } else {
                self.titleLabel.text = "邮箱注册"
                self.accountTopView.title = "邮箱地址"
                self.accountTextField.iconName = "icon_login_email"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "注册"
        configureSubViews()
        configureEvents()
    }
    
    @objc func closeClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func registeredAndLoginButtonClick() {
        if !self.checkValidText(textField: self.accountTextField.textFied) {
            DTProgress.showError(in: self, message: "请输入手机号")
            return
        }
        if !self.checkValidText(textField: self.passwordTextField.textFied) {
            DTProgress.showError(in: self, message: "请输入密码")
            return
        }
        let mobile = self.getValidText(textField: self.accountTextField.textFied)
        let password = self.getValidText(textField: self.passwordTextField.textFied)
        DTProgress.showProgress(in: self)
        let nickname = self.type == .phone ? "\(self.accountTextField.code)\(mobile)" : "\(mobile)"
//        self.viewModel.register(nickName: nickname, password: password, mobile: mobile, countryCode: self.accountTextField.code, validateCode: validateCode).subscribe(onNext: { [weak self] (json) in
//            guard let weakSelf = self else { return }
//            DTProgress.showSuccess(in: weakSelf, message: "注册成功")
//            weakSelf.navigationController?.dismiss(animated: true, completion: nil)
//        }, onError: { [weak self] (error) in
//            guard let weakSelf = self else { return }
//            DTProgress.showError(in: weakSelf, message: "请求失败")
//            debugPrint(error)
//        }).disposed(by: disposeBag)
        
    }
    
    @objc func loginButtonClick() {
        if let resultVC = findResultVC("DTLoginViewController") {
            self.navigationController?.popToViewController(resultVC, animated: true)
        } else {
            Router.routeToClass(DTLoginViewController.self, params: nil)
        }
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
    
    func configureEvents() {
        self.loginButton.addTarget(self, action: #selector(loginButtonClick), for: .touchUpInside)
        self.accountTextField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        loginButton.dt.addGradient(GradientLayer(direction: .leftToRight, colors: [APPColor.color36BDB8, APPColor.color00B170]))
        quickRegisterButton.dt.addGradient(GradientLayer(direction: .leftToRight, colors: [APPColor.color36BDB8, APPColor.color00B170]))
    }
    
    func configureSubViews() {
        self.view.addSubview(titleLabel)
        self.view.addSubview(accountTopView)
        self.view.addSubview(accountTextField)
        self.view.addSubview(passwordTopView)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(sercureButton)
        self.view.addSubview(loginButton)
        self.view.addSubview(loginTitleLabel)
        self.view.addSubview(quickRegisterButton)
        self.view.addSubview(bottomView)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.top.equalTo(10)
        }
        
        accountTopView.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(15)
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
        
        accountTextField.snp.makeConstraints { (make) in
            make.top.equalTo(accountTopView.snp.bottom).offset(6)
            make.left.right.equalTo(accountTopView)
            make.height.equalTo(50)
        }
        
        passwordTopView.snp.makeConstraints { (make) in
            make.top.equalTo(accountTextField.snp.bottom).offset(15)
            make.left.right.equalTo(accountTextField)
        }
        
        passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(passwordTopView.snp.bottom).offset(6)
            make.left.right.equalTo(passwordTopView)
            make.height.equalTo(60)
        }
        
        sercureButton.snp.makeConstraints { (make) in
            make.left.equalTo(passwordTextField)
            make.top.equalTo(passwordTextField.snp.bottom).offset(10)
        }
        
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(sercureButton.snp.bottom).offset(50)
            make.centerX.equalTo(self.view)
            make.left.equalTo(22)
            make.right.equalTo(-22)
            make.height.equalTo(50)
        }
        
        loginTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(loginButton)
            make.top.equalTo(loginButton.snp.bottom).offset(10)
        }
        
        quickRegisterButton.snp.makeConstraints { (make) in
            make.top.equalTo(loginTitleLabel.snp.bottom).offset(30)
            make.left.right.equalTo(loginButton)
            make.height.equalTo(72)
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.height.equalTo(62)
        }
    }

    //MARK - UI
    private lazy var accountTopView = DTLoginProfileView(title: "用户名")
    private lazy var accountTextField = DTTextFieldView(iconName: "icon_login_verify_phone", placeHolder: "8～20个字之间")
    private lazy var passwordTopView = DTLoginProfileView(title: "密码")
    private lazy var passwordTextField = DTTextFieldView(iconName: "icon_login_password", placeHolder: "8～20个字，字母区分大小写。", isSecureTextEntry: true)
    
    
    private lazy var titleLabel:UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.dt.Bold_Font(24)
        titleLabel.textColor = APPColor.color36BDB8
        titleLabel.text = "用户名注册"
        return titleLabel
    }()
    
    private lazy var loginButton:UIButton = {
        let loginButton = UIButton(type: .custom).dt
            .title("注册")
            .font(UIFont.dt.Bold_Font(16))
            .titleColor(APPColor.colorWhite)
            .build
        loginButton.layer.cornerRadius = 25
        loginButton.layer.masksToBounds = true
        return loginButton
    }()
    
    private var sercureButton: DTImageTitleButton = {
        let sercureButton = DTImageTitleButton(space: 5)
        sercureButton.setTitle("显示密码", state: .normal)
        sercureButton.setTitle("显示密码", state: .select)
        sercureButton.setImage(UIImage(named: "icon_login_verify_phone"), state: .normal)
        sercureButton.setImage(UIImage(named: "icon_login_password"), state: .select)
        return sercureButton
    }()
    
    private var loginTitleLabel: UILabel = {
        let loginTitleLabel = UILabel().dt
            .font(UIFont.dt.Font(17))
            .text("完成注册获得5天使用时长")
            .textColor(APPColor.colorWhite.withAlphaComponent(0.8))
            .build
        return loginTitleLabel
    }()
    
    private var quickRegisterButton: UIButton = {
        let quickRegisterButton = UIButton(type: .custom).dt
            .title("快捷注册\n自动生成用户名&密码")
            .font(UIFont.dt.Bold_Font(16))
            .titleColor(APPColor.colorWhite)
            .build
        quickRegisterButton.titleLabel?.lineBreakMode = .byWordWrapping
        quickRegisterButton.titleLabel?.textAlignment = .center
        quickRegisterButton.layer.cornerRadius = 10
        quickRegisterButton.layer.masksToBounds = true
        return quickRegisterButton
    }()
    
    private lazy var bottomView: DTLoginBottomView = {
        let bottomView = DTLoginBottomView()
        bottomView.layer.cornerRadius = 10
        bottomView.layer.masksToBounds = true
        return bottomView
    }()
    
}

extension DTCreateAccountViewController: DTTextFieldViewDelegate {
    func selectCountryClick() {
        Router.routeToClass(DTSelectCountryViewController.self, params: ["delegate":self])
    }
}

extension DTCreateAccountViewController: DTSelectCountryViewControllerDelegate {
    func countrySelect(vc: DTSelectCountryViewController, model: DTCountryItemModel) {
        self.accountTextField.code = model.areaCode
    }
}
