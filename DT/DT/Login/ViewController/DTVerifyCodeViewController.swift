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
        return vc
    }
    
    private let disposeBag = DisposeBag()
    private weak var popupView: DTAlertBaseView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        verifyCodeTextField.placeholder = "请输入验证码"
        codeView.setTitle("获取验证码")
        configSubView()
        configEvents()
    }
    
    @objc private func startCutDown() {
        self.codeView.isUserInteractionEnabled = false
        DTLoginSchedule.timer(duration: 60).subscribe(onNext: { [weak self] (second) in
            guard let weakSelf = self else { return }
            weakSelf.codeView.setTitle("重新发送（\(second)）")
        }, onError: { [weak self] (error) in
            guard let weakSelf = self else { return }
            weakSelf.codeView.setTitle("获取验证码")
            weakSelf.codeView.isUserInteractionEnabled = true
        }, onCompleted: { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.codeView.setTitle("获取验证码")
            weakSelf.codeView.isUserInteractionEnabled = true
        }).disposed(by: disposeBag)
    }
    
    private func configEvents() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(startCutDown))
        codeView.addGestureRecognizer(tap)
        
        registerButton.dt.target(add: self, action: #selector(registerButtonClick))
    }
    
    @objc private func startNetwork() {
        popupView?.alertManager?.dimiss()
    }
    
    @objc private func registerButtonClick() {
        let popupView = DTAlertBaseView(frame: .zero)
        popupView.readData(icon: UIImage(named: "icon_login_password"), title: "注册成功", message: "获取30天免费连接时长")
        popupView.addGradientAction("智能连接,开始上网", titleColor: APPColor.colorWhite, direction: .leftToRight, colors: [APPColor.color36BDB8, APPColor.color00B170], target: self, selector: #selector(startNetwork))
        popupView.finish()
        popupView.alertManager?.show()
        self.popupView = popupView
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
        return codeView
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton(type: .custom).dt
            .font(UIFont.dt.Font(16))
            .title("注册")
            .titleColor(APPColor.colorWhite)
            .build
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        return button
    }()

}
