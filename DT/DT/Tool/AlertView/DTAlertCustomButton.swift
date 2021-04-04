//
//  DTAlertCustomButton.swift
//  DT
//
//  Created by Ye Keyon on 2021/3/23.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit

class DTAlertCustomButton: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubView()
    }
    
    func read(title: String, desc:String, target: Any, selector: Selector) {
        titleLabel.text = title
        descLabel.text = desc
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: target, action: selector)
        addGestureRecognizer(tap)
    }
    
    private func configureSubView() {
        addSubview(self.titleLabel)
        addSubview(self.descLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(10)
            make.height.equalTo(22)
        }
        
        descLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.dt.addGradient(GradientLayer(direction: .leftToRight, colors: [APPColor.color36BDB8, APPColor.color00B170]))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel().dt
            .font(UIFont.dt.Font(16))
            .textColor(UIColor.white)
            .build
        return label
    }()
    
    private lazy var descLabel: UILabel = {
        let label = UILabel().dt
            .font(UIFont.dt.Font(12))
            .textColor(UIColor.white)
            .build
        return label
    }()
}
