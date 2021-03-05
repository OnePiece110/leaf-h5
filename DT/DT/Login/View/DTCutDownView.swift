//
//  DTCutDownView.swift
//  DT
//
//  Created by Ye Keyon on 2021/2/11.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit

class DTCutDownView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.dt.addGradient(GradientLayer(direction: .leftToRight, colors: [APPColor.color36BDB8, APPColor.color00B170]))
    }
    
    private func configSubView() {
        addSubview(codeLabel)
        codeLabel.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(self)
        }
    }
    
    public func setTitle(_ title: String) {
        codeLabel.text = title
    }
    
    private lazy var codeLabel: UILabel = {
        let codeLabel = UILabel().dt
            .font(UIFont.dt.Font(14))
            .textColor(APPColor.colorWhite)
            .build
        return codeLabel
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
