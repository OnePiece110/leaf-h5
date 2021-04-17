//
//  DTVPNLineEditViewController.swift
//  DT
//
//  Created by Ye Keyon on 2021/2/26.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit
import RealmSwift

protocol DTVPNLineEditViewControllerDelegate: class {
    func saveButtonClick()
}

class DTVPNLineEditViewController: DTBaseViewController, Routable{

    static func initWithParams(params: [String : Any]?) -> UIViewController {
        let vc = DTVPNLineEditViewController()
        if let model = params?["model"] as? DTVPNLineModel {
            vc.model = model
        }
        if let delegate = params?["delegate"] as? DTVPNLineEditViewControllerDelegate {
            vc.delegate = delegate
        }
        return vc
    }
    
    private var realm = try! Realm()
    private var model: DTVPNLineModel?
    weak var delegate: DTVPNLineEditViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "配置参数"
        configSubViews()
        configEvents()
        if let model = model {
            configData(model: model)
        }
        let parseButton = UIBarButtonItem(title: "解析URL", style: .done, target: self, action: #selector(parseButtonClick))
        self.navigationItem.rightBarButtonItems = [parseButton]
        
    }
    
    @objc private func parseButtonClick() {
        let alertVC = UIAlertController(title: "解析url", message: nil, preferredStyle: .alert)
        alertVC.addTextField { (textfiled) in
            textfiled.placeholder = "输入URL"
        }
        let action = UIAlertAction(title: "确定", style: .default) { [weak self] (action) in
            guard let weakSelf = self else { return }
            let urlTextField = alertVC.textFields?.first
            if let string = urlTextField?.text,let urlComponents = NSURLComponents(string: string), let queryItems = urlComponents.queryItems  {
                for item in queryItems {
                    switch item.name {
                    case "protocol":
                        weakSelf.rightLabel.text = item.value
                    case "domain":
                        weakSelf.domainTextField.textFied.text = item.value
                    case "port":
                        weakSelf.portTextField.textFied.text = item.value
                    case "password":
                        weakSelf.passwordTextField.textFied.text = item.value
                    case "path":
                        weakSelf.websocketTextField.textFied.text = item.value
                    case "host":
                        weakSelf.websocketHostTextField.textFied.text = item.value
                    default:
                        debugPrint("不符合条件")
                        break
                    }
                }
            }
        }
        alertVC.addAction(action)
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc private func saveButtonClick() {
        if !domainTextField.textFied.dt.isValid() {
            DTProgress.showError(in: self, message: "请填写地址")
            return
        }
        
        if !portTextField.textFied.dt.isValid() {
            DTProgress.showError(in: self, message: "请填写端口")
            return
        }
        
        if !passwordTextField.textFied.dt.isValid() {
            DTProgress.showError(in: self, message: "请填写密码")
            return
        }
        
        
        
        try? realm.write { [weak self] in
            guard let weakSelf = self else { return }
            var result: DTVPNLineModel
            var isNew = false
            let vpnLineModels = realm.objects(DTVPNLineModel.self)
            if let model = weakSelf.model {
                result = model
            } else {
                isNew = true
                result = DTVPNLineModel()
                result.id = vpnLineModels.count
            }
            if isNew {
                weakSelf.realm.add(result)
            }
            
            result.domain = domainTextField.textFied.text ?? ""
            result.port = Int(portTextField.textFied.text ?? "") ?? 443
            result.passwd = passwordTextField.textFied.text ?? ""
            result.path = websocketTextField.textFied.text ?? ""
            result.host = websocketHostTextField.textFied.text ?? ""
            result.proto = rightLabel.text ?? "vless"
            
            weakSelf.popSelf()
            weakSelf.delegate?.saveButtonClick()
        }
    }
    
    private func configEvents() {
        saveButton.dt.target(add: self, action: #selector(saveButtonClick))
        typeView.dt.viewTarget(add: self, action: #selector(typeViewClick))
    }
    
    @objc private func typeViewClick() {
        Router.routeToClass(DTVPNPtotocolViewController.self, params: ["delegate": self])
    }
    
    private func configData(model: DTVPNLineModel) {
        rightLabel.text = model.proto
        domainTextField.textFied.text = model.domain
        portTextField.textFied.text = "\(model.port)"
        passwordTextField.textFied.text = model.passwd
        websocketTextField.textFied.text = model.path
        websocketHostTextField.textFied.text = model.host
    }
    
    private func configSubViews() {
        view.addSubview(typeView)
        view.addSubview(domainTextField)
        view.addSubview(portTextField)
        view.addSubview(passwordTextField)
        view.addSubview(websocketTextField)
        view.addSubview(websocketHostTextField)
        view.addSubview(saveButton)
        
        typeView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            make.height.equalTo(44)
        }
        
        makeConstraint(view: domainTextField, topView: typeView)
        makeConstraint(view: portTextField, topView: domainTextField)
        makeConstraint(view: passwordTextField, topView: portTextField)
        makeConstraint(view: websocketTextField, topView: passwordTextField)
        makeConstraint(view: websocketHostTextField, topView: websocketTextField)
        
        saveButton.snp.makeConstraints { (make) in
            make.height.equalTo(50)
            make.left.right.equalTo(0)
            make.top.equalTo(websocketHostTextField.snp.bottom).offset(50)
        }
    }
    
    private func makeConstraint(view:UIView, topView: UIView) {
        view.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom)
            make.left.right.equalTo(0)
            make.height.equalTo(44)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        saveButton.dt.addGradient(GradientLayer(direction: .leftToRight, colors: [APPColor.color36BDB8, APPColor.color00B170]))
    }
    

    //MARK - ui
    private lazy var rightLabel: UILabel = {
        let rightLabel = UILabel().dt
            .font(UIFont.dt.Font(14))
            .text("vless")
            .textColor(APPColor.colorWhite)
            .isUserInteractionEnabled(true)
            .build
        return rightLabel
    }()
    private lazy var typeView: UIView = {
        let typeView = UIView()
        typeView.backgroundColor = APPColor.color3E5E77
        let titleLabel = UILabel().dt
            .font(UIFont.dt.Font(14))
            .text("类型")
            .textColor(APPColor.colorWhite)
            .isUserInteractionEnabled(true)
            .build
        typeView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(typeView)
            make.left.equalTo(15)
        }
        
        let image = UIImage(named: "icon_link_button_arrow")?.withRenderingMode(.alwaysTemplate)
        let arrowImageView = UIImageView(image: image)
        arrowImageView.tintColor = .white
        typeView.addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(typeView)
            make.right.equalTo(-15)
        }
        
        typeView.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(typeView)
            make.right.equalTo(arrowImageView.snp.left).offset(-5)
        }
        
        return typeView
    }()
    
    private lazy var domainTextField: DTTextFieldView = {
        let textfield = DTTextFieldView(code: "地址", placeHolder: "必填，域名", isAddTap: false, corner: 0)
        return textfield
    }()
    
    private lazy var portTextField: DTTextFieldView = {
        let textfield = DTTextFieldView(code: "端口", placeHolder: "必填，端口", isAddTap: false, corner: 0)
        return textfield
    }()
    
    private lazy var passwordTextField: DTTextFieldView = {
        let textfield = DTTextFieldView(code: "密码", placeHolder: "必填，密码", isAddTap: false, corner: 0)
        return textfield
    }()
    
    private lazy var websocketTextField: DTTextFieldView = {
        let textfield = DTTextFieldView(code: "ws的路径", placeHolder: "选填", isAddTap: false, corner: 0)
        textfield.textFied.text = "/"
        return textfield
    }()
    
    private lazy var websocketHostTextField: DTTextFieldView = {
        let textfield = DTTextFieldView(code: "ws的Host", placeHolder: "选填", isAddTap: false, corner: 0)
        return textfield
    }()
    
    private lazy var saveButton:UIButton = {
        let loginButton = UIButton(type: .custom).dt
            .title("保存")
            .font(UIFont.dt.Bold_Font(16))
            .titleColor(APPColor.colorWhite)
            .build
        loginButton.layer.cornerRadius = 25
        loginButton.layer.masksToBounds = true
        return loginButton
    }()

}

extension DTVPNLineEditViewController: DTVPNPtotocolViewControllerDelegate {
    func vpnProtocolItemClick(proto: String) {
        rightLabel.text = proto
    }
}
