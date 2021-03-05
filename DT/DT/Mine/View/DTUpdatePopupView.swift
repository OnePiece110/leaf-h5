//
//  DTUploadPopupView.swift
//  DT
//
//  Created by Ye Keyon on 2021/1/17.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit
import SnapKit
import StoreKit

class DTUpdatePopupView: UIView {

    var alertManager:DTAlertManager?
    static func updatePopup() -> DTUpdatePopupView {
        let updatePopup = DTUpdatePopupView(frame: CGRect(x: 0, y: 0, width: 275, height: 377))
        updatePopup.layer.cornerRadius = 20
        updatePopup.layer.masksToBounds = true
        updatePopup.alertManager = DTAlertManager(updatePopup)
        return updatePopup
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubView()
    }
    
    private func configSubView() {
        self.addSubview(self.iconImageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.descLabel)
        self.addSubview(self.starButton)
        self.addSubview(self.feedBackButton)
        
        self.iconImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(50)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self.iconImageView.snp.bottom).offset(15)
        }
        
        self.descLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
            make.left.equalTo(14)
            make.right.equalTo(-14)
        }
        
        self.starButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self.descLabel.snp.bottom).offset(15)
            make.size.equalTo(CGSize(width: 235, height: 42))
        }
        
        self.feedBackButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self.starButton.snp.bottom).offset(15)
            make.size.equalTo(CGSize(width: 235, height: 42))
            make.bottom.equalTo(-50)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.dt.addGradient(GradientLayer(direction: .topToBottom, colors: [APPColor.color054369, APPColor.color001E36]))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func update() {
        alertManager?.dimiss()
    }
    
    @objc func cancelUpdate() {
        alertManager?.dimiss()
    }
    
    private var iconImageView = UIImageView(image: UIImage(named: "icon_common_temp"))
    
    private lazy var titleLabel: DTGranibleLabel = {
        let titleLabel = DTGranibleLabel()
        titleLabel.text = "发现新版本"
        titleLabel.font = UIFont.dt.Bold_Font(24)
        titleLabel.direction = .left
        titleLabel.colors = [APPColor.color36BDB8, APPColor.color00B170]
        return titleLabel
    }()
    
    private lazy var descLabel: UILabel = {
        let descLabel = UILabel()
        descLabel.lineBreakMode = .byCharWrapping
        descLabel.text = "发现了灯塔加速器最新的v2.0版本\n我们强烈建议您进行更新，是否立即更新？"
        descLabel.font = UIFont.dt.Font(14)
        descLabel.textColor = APPColor.colorF6F6F6
        descLabel.numberOfLines = 0
        descLabel.textAlignment = .center
        return descLabel
    }()
    
    private lazy var starButton: UIButton = {
        let button = UIButton(type: .custom)
        let gradientImage = UIImage.dt.fromGradientWithDirection(.leftToRight, frame: CGRect(x: 0, y: 0, width: 235, height: 42), colors: [APPColor.color36BDB8, APPColor.color00B170])
        button.setBackgroundImage(gradientImage, for: .normal)
        button.setTitle("立即更新", for: .normal)
        button.titleLabel?.font = UIFont.dt.Bold_Font(16)
        button.addTarget(self, action: #selector(update), for: .touchUpInside)
        button.layer.cornerRadius = 21
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var feedBackButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage.dt.imageWithColor(color: APPColor.colorSubBgView), for: .normal)
        button.setTitle("暂不更新", for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        button.titleLabel?.font = UIFont.dt.Bold_Font(16)
        button.addTarget(self, action: #selector(cancelUpdate), for: .touchUpInside)
        button.layer.cornerRadius = 21
        button.layer.masksToBounds = true
        return button
    }()

}
