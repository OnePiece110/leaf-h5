//
//  DTSelecViewCell.swift
//  DT
//
//  Created by Ye Keyon on 2021/2/12.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit

class DTSelecViewCell: DTBaseTableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configSubViews()
    }
    
    func readData(_ data: String) {
        titleLabel.text = data
    }
    
    private func configSubViews() {
        contentView.backgroundColor = APPColor.colorWhite.withAlphaComponent(0.1)
        contentView.addSubview(titleLabel)
        contentView.addSubview(lineView)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(0)
            make.left.equalTo(15)
            make.right.equalTo(-15)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalTo(titleLabel)
            make.bottom.equalTo(0)
            make.height.equalTo(1)
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel().dt
            .font(UIFont.dt.Font(14))
            .textColor(APPColor.colorWhite)
            .textAlignment(.center)
            .build
        return titleLabel
    }()
    
    private lazy var lineView:UIView = {
       let lineView = UIView()
        lineView.backgroundColor = APPColor.color235476
        return lineView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
