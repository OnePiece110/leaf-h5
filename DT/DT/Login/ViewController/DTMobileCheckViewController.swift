//
//  DTMobileCheckViewController.swift
//  DT
//
//  Created by Ye Keyon on 2021/2/11.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit
import RxSwift

class DTMobileCheckViewController: DTBaseViewController, Routable {
    
    static func initWithParams(params: [String : Any]?) -> UIViewController {
        let vc = DTMobileCheckViewController()
        if let nickName = params?["nickName"] as? String{
            vc.viewModel.nickName = nickName
        }
        if let mobile = params?["mobile"] as? String {
            vc.descText = "您已绑定手机\(mobile)"
        }
        return vc
    }
    
    private var viewModel = DTMobileCheckViewModel()
    private var descText = ""
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "验证手机"
        configSubView()
        phoneTextField.placeholder = "请输入手机号"
    }
    
    @objc func nextButtonClick() {
        let (isValid, mobile) = DTConstants.checkValidText(textField: self.phoneTextField.textField)
        if !isValid {
            DTProgress.showError(in: self, message: "请输入手机号")
            return
        }
        DTProgress.showProgress(in: self)
        self.viewModel.mobileCheck(mobile: mobile).subscribe{ [weak self] (json) in
            guard let weakSelf = self else { return }
            DTProgress.dismiss(in: weakSelf)
            if json.entry {
                Router.routeToClass(DTVerifyCodeViewController.self, params: ["nickName": weakSelf.viewModel.nickName, "mobile": mobile])
            } else {
                DTProgress.showError(in: weakSelf, message: "验证失败")
            }
        } onError: { [weak self] (error) in
            guard let weakSelf = self else { return }
            DTProgress.showError(in: weakSelf, message: "请求失败")
        }.disposed(by: disposeBag)
        
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
        
        accountTopView.title = self.descText
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nextButton.dt.addGradient(GradientLayer(direction: .leftToRight, colors: [APPColor.color36BDB8, APPColor.color00B170]))
    }
    
    // MARK: -- UI
    private lazy var accountTopView = DTLoginProfileView(title: "验证手机号")
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
