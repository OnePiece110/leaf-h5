//
//  DTSettingCell.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/12.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

class DTSettingCell: DTBaseTableViewCell {

    private let radiusView = DTCustomRadiusView()
    
    private lazy var titleLabel:UILabel = {
       let titleLabel = UILabel()
        titleLabel.font = UIFont.dt.Font(14)
        titleLabel.textColor = .white
        return titleLabel
    }()
    
    private lazy var descLabel:UILabel = {
       let descLabel = UILabel()
        descLabel.font = UIFont.dt.Font(14)
        descLabel.text = "智能模式（推荐）"
        descLabel.textColor = UIColor.white
        return descLabel
    }()
    
    private lazy var arrowImageView:UIImageView = {
        let image = UIImage(named: "icon_link_button_arrow")?.withRenderingMode(.alwaysTemplate)
        let arrowImageView = UIImageView(image: image)
        arrowImageView.tintColor = .white
        return arrowImageView
    }()
    
    private lazy var lineView:UIView = {
       let lineView = UIView()
        lineView.backgroundColor = APPColor.line
        return lineView
    }()
    
    var model:DTSettingRowModel = DTSettingRowModel(title: "默认线路设置", descText: "智能选择线路", type: .proxyMode) {
        didSet {
            radiusView.topLeftRadius = model.topLeftRadius
            radiusView.topRightRadius = model.topRightRadius
            radiusView.bottomLeftRadius = model.bottomLeftRadius
            radiusView.bottomRightRadius = model.bottomRightRadius
            titleLabel.text = model.title
            descLabel.text = model.descText
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
        radiusView.backgroundColor = APPColor.colorSubBgView
        self.contentView.addSubview(radiusView)
        radiusView.addSubview(descLabel)
        radiusView.addSubview(titleLabel)
        radiusView.addSubview(arrowImageView)
        radiusView.addSubview(lineView)
        
        radiusView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.bottom.equalTo(0)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(radiusView)
            make.left.equalTo(20)
        }
        
        arrowImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(radiusView)
            make.width.equalTo(7)
            make.height.equalTo(10)
            make.right.equalTo(-13)
        }
        
        descLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(radiusView)
            make.right.equalTo(arrowImageView.snp.left).offset(-10)
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(10)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(0)
            make.height.equalTo(1)
        }
    }
}
