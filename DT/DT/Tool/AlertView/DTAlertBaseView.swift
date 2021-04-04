//
//  DTAlertBaseView.swift
//  DT
//
//  Created by Ye Keyon on 2021/2/11.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit

struct DTGradientAction {
    var button: UIButton
    var gradientLayer: GradientLayer
}

class DTAlertBaseView: UIView {
    
    private var gradientButton = [DTGradientAction]()
    private var lastView: UIView?
    var alertManager:DTAlertManager?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubView()
        self.alertManager = DTAlertManager(self)
    }
    
    private func configSubView() {
        addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.equalTo(50)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        lastView = topView
    }
    
    func readData(icon: UIImage?, title: String, message: String) {
        topView.readData(icon: icon, title: title, message: message)
    }
    
    func addAction(_ title: String, titleColor: UIColor, bgColor: UIColor, target: Any, selector: Selector) {
        let button = UIButton(type: .custom).dt
            .title(title)
            .font(UIFont.dt.Font(14))
            .titleColor(titleColor)
            .target(add: target, action: selector)
            .backgroundColor(bgColor)
            .build
        button.layer.cornerRadius = 21
        button.layer.masksToBounds = true
        addButton(button: button)
    }
    
    func addGradientAction(_ title: String, titleColor: UIColor, direction: GradientDirection, colors: [UIColor], target: Any, selector: Selector) {
        let button = UIButton(type: .custom).dt
            .title(title)
            .font(UIFont.dt.Font(14))
            .titleColor(titleColor)
            .target(add: target, action: selector)
            .build
        button.layer.cornerRadius = 21
        button.layer.masksToBounds = true
        gradientButton.append(DTGradientAction(button: button, gradientLayer: GradientLayer(direction: direction, colors: colors)))
        addButton(button: button)
    }
    
    func addDesc(_ title: String, titleColor: UIColor) {
        let label = UILabel().dt
            .text(title)
            .textColor(titleColor)
            .font(UIFont.dt.Font(12))
            .textAlignment(.center)
            .numberOfLines(0)
            .build
        addLabel(label: label)
    }
    
    func addTwoButton(titleOne: String,
                      titleTwo: String,
                      descTwo: String,
                      target: Any,
                      selectorOne: Selector,
                      selectorTwo: Selector) {
        guard let lastView = lastView else {
            return
        }
        let bgView = UIView()
        addSubview(bgView)
        
        let button = UIButton(type: .custom).dt
            .title(titleOne)
            .font(UIFont.dt.Font(14))
            .titleColor(APPColor.color36BDB8)
            .target(add: target, action: selectorOne)
            .backgroundColor(UIColor.clear)
            .build
        button.layer.borderWidth = 0.5
        button.layer.borderColor = APPColor.color36BDB8.cgColor
        button.layer.cornerRadius = 21
        
        let customButton = DTAlertCustomButton(frame: .zero)
        customButton.read(title: "手机号注册", desc: "可得30天使用时长", target: self, selector: selectorTwo)
        customButton.layer.cornerRadius = 21
        customButton.layer.masksToBounds = true
        
        bgView.addSubview(button)
        bgView.addSubview(customButton)
        
        bgView.snp.makeConstraints { (make) in
            make.top.equalTo(lastView.snp.bottom).offset(15)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(59)
        }
        
        button.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(0)
            make.left.equalTo(0)
        }
        
        customButton.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(0)
            make.right.equalTo(0)
            make.left.equalTo(button.snp.right).offset(13)
            make.width.equalTo(button.snp.width)
        }
        
        self.lastView = bgView
    }
    
    private func addButton(button: UIButton) {
        guard let lastView = lastView else {
            return
        }
        addSubview(button)
        
        button.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(lastView.snp.bottom).offset(15)
            make.height.equalTo(42)
            make.width.equalTo(235)
        }
        
        self.lastView = button
    }
    
    private func addLabel(label: UILabel) {
        guard let lastView = lastView else {
            return
        }
        
        addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(lastView.snp.bottom).offset(10)
        }
        
        self.lastView = label
    }
    
    func finish() {
        guard let lastView = lastView else {
            return
        }
        lastView.translatesAutoresizingMaskIntoConstraints = false
        let bottomContraint = NSLayoutConstraint.init(item: lastView,
                                                         attribute: .bottom,
                                                         relatedBy: .equal,
                                                         toItem: self,
                                                         attribute: .bottom,
                                                         multiplier: 1,
                                                         constant: -50)
        NSLayoutConstraint.activate([bottomContraint])
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.dt.addGradient(GradientLayer(direction: .topToBottom, colors: [APPColor.color054369, APPColor.color082138]))
        for item in gradientButton {
            item.button.dt.addGradient(item.gradientLayer)
        }
    }
    
    //MARK: -- UI
    private var topView: DTAlertTopView = {
        let topView = DTAlertTopView(frame: .zero)
        return topView
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
