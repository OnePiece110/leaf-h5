//
//  DTLoginBottomView.swift
//  DT
//
//  Created by Ye Keyon on 2021/2/11.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit

protocol DTLoginBottomViewDelegate:class {
    func registerButtonClick()
}

class DTLoginBottomView: UIView {
    
    weak var delegate: DTLoginBottomViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubView()
        configEvents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func configSubView() {
        addSubview(bottomTitleLabel)
        addSubview(bottomDescLabel)
        addSubview(registerButton)
        
        bottomTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(10)
            make.height.equalTo(17)
        }
        
        bottomDescLabel.snp.makeConstraints { (make) in
            make.left.equalTo(bottomTitleLabel)
            make.top.equalTo(bottomTitleLabel.snp.bottom)
            make.height.equalTo(25)
        }
        
        registerButton.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 92, height: 28))
            make.centerY.equalTo(self)
            make.right.equalTo(-15)
        }
    }
    
    private func configEvents() {
        registerButton.dt.target(add: self, action: #selector(registerButtonClick))
    }
    
    @objc func registerButtonClick() {
        delegate?.registerButtonClick()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.dt.addGradient(GradientLayer(direction: .topToBottom, colors: [APPColor.color26B3AD, APPColor.color09598B]))
        registerButton.dt.addGradient(GradientLayer(direction: .leftToRight, colors: [APPColor.color36BDB8, APPColor.color00B170]))
    }

    private lazy var bottomTitleLabel: UIView = {
        let bottomTitleLabel = UILabel().dt
            .font(UIFont.dt.Font(12))
            .textColor(APPColor.colorWhite)
            .text("4月31日之前完成注册")
            .build
        return bottomTitleLabel
    }()
    
    private lazy var bottomDescLabel: UIView = {
        let bottomDescLabel = UILabel().dt
            .font(UIFont.dt.Bold_Font(18))
            .textColor(APPColor.colorWhite)
            .text("最多可获得30天使用时长")
            .build
        return bottomDescLabel
    }()
    
    private lazy var registerButton: UIButton = {
        let registerButton = UIButton(type: .custom).dt
            .title("立即注册")
            .titleColor(APPColor.colorWhite)
            .font(UIFont.dt.Bold_Font(16))
            .build
        registerButton.layer.cornerRadius = 14
        registerButton.layer.masksToBounds = true
        return registerButton
    }()

}
