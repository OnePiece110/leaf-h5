//
//  DTPaddingLabel.swift
//  DT
//
//  Created by Ye Keyon on 2021/2/12.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit

class DTPaddingLabel: UIView {

    init(edges: UIEdgeInsets, isAddGradient: Bool = false) {
        super.init(frame: .zero)
        configSubView(edges: edges)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.dt.addGradient(GradientLayer(direction: .leftToRight, colors: [APPColor.color36BDB8, APPColor.color00B170]))
    }
    
    private func configSubView(edges: UIEdgeInsets) {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(edges)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func font(_ font:UIFont) {
        titleLabel.font = font
    }
    
    func title(_ title: String) {
        titleLabel.text = title
    }
    
    func titleColor(_ color: UIColor) {
        titleLabel.textColor = color
    }
    
    private var titleLabel = UILabel()
    
}
