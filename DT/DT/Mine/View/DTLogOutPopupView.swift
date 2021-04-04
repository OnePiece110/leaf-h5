//
//  DTLogOutPopupView.swift
//  DT
//
//  Created by Ye Keyon on 2021/2/9.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit

protocol DTLogOutPopupViewDelegate:class {
    func sureButtonClick()
    func cancelButtonClick()
}

class DTLogOutPopupView: UIView {

    weak var delegate: DTLogOutPopupViewDelegate?
    var alertManager:DTAlertManager?
    static func logOutPopup() -> DTLogOutPopupView {
        let logOutPopup = DTLogOutPopupView(frame: CGRect(x: 0, y: 0, width: 325, height: 140))
        logOutPopup.layer.cornerRadius = 10
        logOutPopup.layer.masksToBounds = true
        logOutPopup.alertManager = DTAlertManager(logOutPopup)
        return logOutPopup
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubView()
    }
    
    func configSubView() {
        self.addSubview(titleLabel)
        self.addSubview(lineView)
        self.addSubview(sureButton)
        self.addSubview(cancelButton)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(0)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(90)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(1)
            make.top.equalTo(titleLabel.snp.bottom)
        }
        
        sureButton.snp.makeConstraints { (make) in
            make.left.bottom.equalTo(0)
            make.height.equalTo(50)
            make.width.equalTo(162.5)
            make.top.equalTo(lineView.snp.bottom)
        }
        
        cancelButton.snp.makeConstraints { (make) in
            make.left.equalTo(sureButton.snp.right)
            make.top.equalTo(lineView.snp.bottom)
            make.bottom.right.equalTo(0)
            make.height.width.equalTo(sureButton)
        }
    }
    
    @objc func sureClick() {
        alertManager?.removeView()
        delegate?.sureButtonClick()
    }
    
    @objc func cancelClick() {
        alertManager?.dimiss()
        delegate?.cancelButtonClick()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.dt.addGradient(GradientLayer(direction: .topToBottom, colors: [APPColor.color054369, APPColor.color001E36]))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   lazy var titleLabel: UILabel = {
        let titleLabel = UILabel().dt
            .text("您确定退出登录吗？")
            .font(UIFont.dt.Font(14))
            .textColor(UIColor.dt.hex("#ffffff"))
            .textAlignment(.center)
            .numberOfLines(0)
            .build
        return titleLabel
    }()
    
    private lazy var lineView: UIView = {
        let lineView = UIView().dt
            .backgroundColor(UIColor.dt.hex("#235476"))
            .build
        return lineView
    }()
    
    private lazy var sureButton: UIButton = {
        let sureButton = UIButton(type: .custom).dt
            .title("确定")
            .titleColor(APPColor.colorWhite)
            .font(UIFont.dt.Font(14))
            .target(add: self, action: #selector(sureClick))
            .backgroundColor(.clear)
            .build
        return sureButton
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .custom).dt
            .title("取消")
            .titleColor(APPColor.color36BDB8)
            .font(UIFont.dt.Font(14))
            .target(add: self, action: #selector(cancelClick))
            .backgroundColor(.clear)
            .build
        return cancelButton
    }()

}
