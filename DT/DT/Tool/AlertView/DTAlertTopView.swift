//
//  DTAlertTopView.swift
//  DT
//
//  Created by Ye Keyon on 2021/2/11.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit

class DTAlertTopView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubView()
    }
    
    func configSubView() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(messageLabel)
        
        iconImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.top.equalTo(0)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconImageView.snp.bottom).offset(15)
            make.left.right.equalTo(0)
        }
        
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconImageView.snp.bottom).offset(53)
            make.left.right.bottom.equalTo(0)
        }
    }
    
    func readData(icon: UIImage?, title: String, message: String) {
        iconImageView.image = icon
        titleLabel.text = title
        messageLabel.text = message
    }
    
    private var iconImageView: UIImageView = {
        let iconImageView = UIImageView()
        iconImageView.backgroundColor = APPColor.colorWhite
        iconImageView.layer.cornerRadius = 10
        iconImageView.layer.masksToBounds = true
        return iconImageView
    }()
    
    private var titleLabel: DTGranibleLabel = {
        let titleLabel = DTGranibleLabel()
        titleLabel.font = UIFont.dt.Bold_Font(24)
        titleLabel.direction = .left
        titleLabel.colors = [APPColor.color36BDB8, APPColor.color00B170]
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    private var messageLabel: UILabel = {
        let messageLabel = UILabel().dt
            .font(UIFont.dt.Font(14))
            .textColor(APPColor.colorF6F6F6)
            .textAlignment(.center)
            .build
        return messageLabel
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
