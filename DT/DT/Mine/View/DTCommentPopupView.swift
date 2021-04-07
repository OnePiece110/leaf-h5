//
//  DTCommentPopupView.swift
//  DT
//
//  Created by Ye Keyon on 2021/1/17.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit
import SnapKit
import StoreKit

class DTCommentPopupView: UIView {
    
    var alertManager:DTAlertManager?
    static func commentPopup() -> DTCommentPopupView {
        let commentPopup = DTCommentPopupView(frame: CGRect(x: 0, y: 0, width: 275, height: 377))
        commentPopup.layer.cornerRadius = 20
        commentPopup.layer.masksToBounds = true
        commentPopup.alertManager = DTAlertManager(commentPopup)
        return commentPopup
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func starButtonClick() {
        if SKStoreReviewController.responds(to: #selector(SKStoreReviewController.requestReview)) {
            let window = UIApplication.dt.currentWindow()
            window?.endEditing(true)
            alertManager?.dimiss()
            SKStoreReviewController.requestReview()
        }
    }
    
    @objc func feedbackButtonClick() {
        alertManager?.dimiss()
        Router.routeToClass(DTFeedbackViewController.self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.dt.addGradient(GradientLayer(direction: .topToBottom, colors: [APPColor.color054369, APPColor.color001E36]))
    }
    
    private var iconImageView = UIImageView(image: UIImage(named: "icon_star_popup"))
    private lazy var titleLabel: DTGranibleLabel = {
        let titleLabel = DTGranibleLabel()
        titleLabel.text = "喜欢引力加速器吗?"
        titleLabel.font = UIFont.dt.Bold_Font(24)
        titleLabel.direction = .left
        titleLabel.colors = [APPColor.color36BDB8, APPColor.color00B170]
        return titleLabel
    }()
    
    private lazy var descLabel: UILabel = {
        let descLabel = UILabel()
        descLabel.lineBreakMode = .byCharWrapping
        descLabel.text = "如果您喜欢引力加速器，请给我们5星鼓励哦"
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
        button.setTitle("5星鼓励", for: .normal)
        button.titleLabel?.font = UIFont.dt.Bold_Font(16)
        button.addTarget(self, action: #selector(starButtonClick), for: .touchUpInside)
        button.layer.cornerRadius = 21
        button.layer.masksToBounds = true
        return button
    }()
    
    private lazy var feedBackButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setBackgroundImage(UIImage.dt.imageWithColor(color: APPColor.colorSubBgView), for: .normal)
        button.setTitle("反馈问题", for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        button.titleLabel?.font = UIFont.dt.Bold_Font(16)
        button.addTarget(self, action: #selector(feedbackButtonClick), for: .touchUpInside)
        button.layer.cornerRadius = 21
        button.layer.masksToBounds = true
        return button
    }()
    
}
