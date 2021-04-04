//
//  DTCustomButton.swift
//  DT
//
//  Created by Ye Keyon on 2021/4/3.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit

class DTCustomButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont.dt.Font(16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.dt.addGradient(GradientLayer(direction: .leftToRight, colors: [APPColor.color36BDB8, APPColor.color00B170]))
    }
}
