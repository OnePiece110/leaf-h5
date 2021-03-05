//
//  DTLogoutCell.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/12.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

class DTLogoutCell: DTBaseTableViewCell {

    private let radiusView = UIView()
    
    private lazy var titleLabel: DTGranibleLabel = {
        let titleLabel = DTGranibleLabel()
        titleLabel.text = "退出登录"
        titleLabel.font = UIFont.dt.Bold_Font(16)
        titleLabel.direction = .left
        titleLabel.colors = [APPColor.color36BDB8, APPColor.color00B170]
        return titleLabel
    }()
    
    var model:DTUserProfileRowModel = DTUserProfileRowModel(title: "默认线路设置", type: .bindInvite) {
        didSet {
            radiusView.layer.cornerRadius = 25
            radiusView.layer.masksToBounds = true
            titleLabel.text = model.title
        }
    }
    
    var mineModel:DTMineRowModel = DTMineRowModel(title: "退出登录", iconName: "", type: .logout) {
        didSet {
            radiusView.layer.cornerRadius = 25
            radiusView.layer.masksToBounds = true
            titleLabel.text = mineModel.title
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        configureSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureSubView() {
        radiusView.backgroundColor = .clear
        radiusView.layer.borderWidth = 1
        radiusView.layer.borderColor = APPColor.color36BDB8.cgColor
        self.contentView.addSubview(radiusView)
        radiusView.addSubview(titleLabel)
        
        radiusView.snp.makeConstraints { (make) in
            make.left.equalTo(22)
            make.right.equalTo(-22)
            make.top.bottom.equalTo(0)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(radiusView)
        }
    }
}
