//
//  DTDefaultRouteCell.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/12.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

class DTDefaultRouteCell: DTBaseTableViewCell {

    private let radiusView = DTCustomRadiusView()
    
    private lazy var titleLabel:UILabel = {
       let titleLabel = UILabel()
        titleLabel.font = UIFont.dt.Bold_Font(14)
        titleLabel.textColor = .white
        return titleLabel
    }()
    
    private lazy var descLabel:UILabel = {
       let descLabel = UILabel()
        descLabel.font = UIFont.dt.Font(12)
        descLabel.text = "智能选择最合适的高速线路"
        descLabel.textColor = UIColor.white.withAlphaComponent(0.4)
        return descLabel
    }()
    
    private lazy var selectImageView:UIImageView = {
       let selectImageView = UIImageView(image: #imageLiteral(resourceName: "icon_common_arrow_right"))
        return selectImageView
    }()
    
    private lazy var lineView:UIView = {
       let lineView = UIView()
        lineView.backgroundColor = APPColor.line
        return lineView
    }()
    
    var model:DTDefualtRouteRowModel = DTDefualtRouteRowModel(title: "智能选择线路", descText: "智能选择最合适的高速线路", isSelected: true) {
        didSet {
            radiusView.topLeftRadius = model.topLeftRadius
            radiusView.topRightRadius = model.topRightRadius
            radiusView.bottomLeftRadius = model.bottomLeftRadius
            radiusView.bottomRightRadius = model.bottomRightRadius
            titleLabel.text = model.title
            descLabel.text = model.descText
            selectImageView.image = model.isSelected ? UIImage(named: "icon_common_select") : UIImage(named: "icon_common_unselect")
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
        radiusView.addSubview(selectImageView)
        radiusView.addSubview(lineView)
        
        radiusView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.bottom.equalTo(0)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(14)
            make.left.equalTo(15)
            make.height.equalTo(22)
        }
        
        selectImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(radiusView)
            make.size.equalTo(CGSize(width: 70, height: 30))
            make.right.equalTo(-10)
        }
        
        descLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalTo(titleLabel.snp.left)
            make.height.equalTo(20)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(0)
            make.height.equalTo(1)
        }
    }

}
