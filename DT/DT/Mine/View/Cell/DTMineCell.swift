//
//  DTMineCell.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/4.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

class DTMineCell: DTBaseTableViewCell {
    
    var model:DTMineRowModel = DTMineRowModel(title: "常见问题", iconName: "icon_mine_question", type: .tool) {
        didSet {
            radiusView.topLeftRadius = model.topLeftRadius
            radiusView.topRightRadius = model.topRightRadius
            radiusView.bottomLeftRadius = model.bottomLeftRadius
            radiusView.bottomRightRadius = model.bottomRightRadius
            iconImageView.image = UIImage(named: model.iconName)
            titleLabel.text = model.title
            let checkType = model.type != .update
            descLabel.isHidden = checkType
            descImageView.isHidden = checkType
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
        radiusView.addSubview(iconImageView)
        radiusView.addSubview(titleLabel)
        radiusView.addSubview(arrowImageView)
        radiusView.addSubview(lineView)
        radiusView.addSubview(descImageView)
        radiusView.addSubview(descLabel)
        
        radiusView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.bottom.equalTo(0)
        }
        
        iconImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(radiusView)
            make.left.equalTo(22)
            make.width.height.equalTo(22)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(iconImageView)
            make.left.equalTo(iconImageView.snp.right).offset(15)
        }
        
        arrowImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(radiusView)
            make.width.equalTo(7)
            make.height.equalTo(10)
            make.right.equalTo(-15)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(0)
            make.height.equalTo(1)
        }
        
        descLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(radiusView)
            make.right.equalTo(arrowImageView.snp.left).offset(-15)
        }
        
        descImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(radiusView)
            make.right.equalTo(descLabel.snp.left).offset(-5)
            make.size.equalTo(CGSize(width: 10, height: 10))
        }
        
    }
    
    private let radiusView = DTCustomRadiusView()
    
    private lazy var iconImageView:UIImageView = {
        let iconImageView = UIImageView()
        return iconImageView
    }()
    
    private lazy var titleLabel:UILabel = {
       let titleLabel = UILabel()
        titleLabel.font = UIFont.dt.Font(14)
        titleLabel.textColor = .white
        return titleLabel
    }()
    
    private lazy var descImageView:UIImageView = {
        let descImageView = UIImageView(image: UIImage(named: "icon_mine_update_small"))
        return descImageView
    }()
    
    private lazy var descLabel:UILabel = {
       let descLabel = UILabel()
        descLabel.font = UIFont.dt.Font(14)
        descLabel.text = "V2.6"
        descLabel.textColor = APPColor.colorWhite
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
        lineView.backgroundColor = APPColor.color235476
        return lineView
    }()
}
