//
//  DTVerifyCodeViewController.swift
//  DT
//
//  Created by Ye Keyon on 2021/2/11.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit
import RxSwift

class DTVerifyCodeViewController: DTBaseViewController, Routable {

    static func initWithParams(params: [String : Any]?) -> UIViewController {
        let vc = DTVerifyCodeViewController()
        if let nickName = params?["nickName"] as? String, let mobile = params?["mobile"] as? String {
            vc.viewModel.mobile = mobile
            vc.viewModel.nickName = nickName
        }
        return vc
    }
    
    private let disposeBag = DisposeBag()
    private weak var popupView: DTAlertBaseView?
    private var viewModel = DTVerifyCodeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verifyCodeTextField.placeholder = "请输入验证码"
        codeView.setTitle("获取验证码")
        configSubView()
        DispatchQueue.main.async {
            self.codeView.isUserInteractionEnabled = false
            self.startCutDown()
        }
    }
    
    @objc private func changePhoneButtonClick() {
        Router.routeToClass(DTAddPhoneViewController.self, params: ["nickName": viewModel.nickName])
    }
    
    @objc private func startNetwork() {
        popupView?.alertManager?.dimiss()
    }
    
    @objc private func registerButtonClick() {
        
        let (isValid, value) = DTConstants.checkValidText(textField: self.verifyCodeTextField.textField)
        if !isValid {
            DTProgress.showError(in: self, message: "请输入验证码")
            return
        }
        DTProgress.showProgress(in: self)
        self.viewModel.codeCheck(validateCode: value).subscribe { [weak self] (json) in
            guard let weakSelf = self else { return }
            if weakSelf.viewModel.isCheckSuccess {
                Router.routeToClass(DTResetPasswordViewController.self, params: ["nickName": weakSelf.viewModel.nickName, "mobile": weakSelf.viewModel.mobile, "validateCode": value])
            } else {
                DTProgress.showError(in: weakSelf, message: "验证失败")
            }
        } onError: { [weak self] (err) in
            guard let weakSelf = self else { return }
            DTProgress.showError(in: weakSelf, message: "请求失败")
        }.disposed(by: disposeBag)
        
//        let popupView = DTAlertBaseView(frame: .zero)
//        popupView.readData(icon: UIImage(named: "icon_login_password"), title: "注册成功", message: "获取30天免费连接时长")
//        popupView.addGradientAction("智能连接,开始上网", titleColor: APPColor.colorWhite, direction: .leftToRight, colors: [APPColor.color36BDB8, APPColor.color00B170], target: self, selector: #selector(startNetwork))
//        popupView.finish()
//        popupView.alertManager?.show()
//        self.popupView = popupView
    }
    
    private func configSubView() {
        view.addSubview(titleLabel)
        view.addSubview(verifyCodeTextField)
        view.addSubview(codeView)
        view.addSubview(registerButton)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(22)
        }
        
        verifyCodeTextField.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(titleLabel.snp.bottom).offset(28)
            make.height.equalTo(50)
        }
        
        codeView.snp.makeConstraints { (make) in
            make.left.equalTo(verifyCodeTextField.snp.right).offset(10)
            make.right.equalTo(-10)
            make.centerY.equalTo(verifyCodeTextField)
            make.size.equalTo(CGSize(width: 132, height: 50))
        }
        
        registerButton.snp.makeConstraints { (make) in
            make.top.equalTo(codeView.snp.bottom).offset(50)
            make.left.equalTo(22)
            make.right.equalTo(-22)
            make.height.equalTo(50)
        }
        
        titleLabel.text = "已向您的手机\(viewModel.mobile)发送验证码"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        registerButton.dt.addGradient(GradientLayer(direction: .leftToRight, colors: [APPColor.color36BDB8, APPColor.color00B170]))
    }
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel().dt
            .font(UIFont.dt.Font(16))
            .textColor(APPColor.colorWhite)
            .text("已向您的手机*********16发送验证码")
            .textAlignment(.center)
            .build
        return titleLabel
    }()
    
    private lazy var verifyCodeTextField: DTPaddingTextField = {
        let verifyCodeTextField = DTPaddingTextField(padding: 15)
        verifyCodeTextField.layer.cornerRadius = 10
        verifyCodeTextField.layer.masksToBounds = true
        return verifyCodeTextField
    }()
    
    private lazy var codeView: DTCutDownView = {
        let codeView = DTCutDownView(frame: .zero)
        codeView.layer.cornerRadius = 25
        codeView.layer.masksToBounds = true
        codeView.delegate = self
        return codeView
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton(type: .custom).dt
            .font(UIFont.dt.Font(16))
            .title("确定")
            .titleColor(APPColor.colorWhite)
            .target(add: self, action: #selector(registerButtonClick))
            .build
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var changePhoneButton:UIButton = {
        let forgetAccountButton = UIButton(type: .custom).dt
            .title("点击换个手机")
            .font(UIFont.dt.Font(14))
            .titleColor(APPColor.color36BDB8)
            .target(add: self, action: #selector(changePhoneButtonClick))
            .build
        return forgetAccountButton
    }()
}


extension DTVerifyCodeViewController: DTCutDownViewDelegate {
    func startCutDown() {
        DTProgress.showProgress(in: self)
        viewModel.sendCode(mobile: viewModel.mobile, countryCode: viewModel.countryCode).subscribe { [weak self] (json) in
            guard let weakSelf = self else { return }
            DTProgress.dismiss(in: weakSelf)
            weakSelf.codeView.startCutDownAction()
        } onError: { [weak self] (err) in
            guard let weakSelf = self else { return }
            DTProgress.showError(in: weakSelf, message: "请求失败")
        }.disposed(by: disposeBag)
    }
}
