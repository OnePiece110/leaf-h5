//
//  DTRouteSectionCell.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/18.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

class DTRouteSectionCell: DTBaseTableViewCell {

    private let radiusView = DTCustomRadiusView()
        
    lazy var iconImageView:UIImageView = {
        let iconImageView = UIImageView()
        iconImageView.layer.cornerRadius = 17
        iconImageView.layer.masksToBounds = true
        return iconImageView
    }()
    
    lazy var titleLabel:UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.dt.Bold_Font(16)
        titleLabel.textColor = APPColor.colorF6F6F6
        return titleLabel
    }()
    
    lazy var lineView:UIView = {
        let lineView = UIView()
        lineView.backgroundColor = APPColor.color235476
        return lineView
    }()
    
    lazy var arrowImageView:UIImageView = {
        let iconImage = UIImageView()
        return iconImage
    }()
    
    var model:DTServerGroupData = DTServerGroupData()  {
        didSet {
            titleLabel.text = model.groupName
            let arrowImageText = model.isOpen ? "icon_common_arrow_up" : "icon_common_arrow_down"
            if model.isOpen && model.serverVOList.count > 0 {
                radiusView.topCorner = 10
            } else {
                radiusView.corner = 10
            }
            let image = UIImage(named: arrowImageText)?.withRenderingMode(.alwaysTemplate)
            arrowImageView.image = image
            arrowImageView.tintColor = .white
            iconImageView.kf.setImage(with: URL(string: model.grouoLogo), placeholder: nil)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubViews() {
        radiusView.backgroundColor = APPColor.colorSubBgView
        radiusView.corner = 10
        self.contentView.addSubview(radiusView)
        radiusView.addSubview(self.iconImageView)
        radiusView.addSubview(self.titleLabel)
        radiusView.addSubview(self.lineView)
        radiusView.addSubview(self.arrowImageView)
        
        radiusView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        }
        
        self.iconImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(radiusView)
            make.left.equalTo(15)
            make.size.equalTo(CGSize(width: 34, height: 34))
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(radiusView)
            make.height.equalTo(22)
            make.left.equalTo(self.iconImageView.snp.right).offset(15)
        }
        
        self.lineView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-1)
            make.height.equalTo(1)
        }
        
        self.arrowImageView.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.size.equalTo(CGSize(width: 15, height: 10))
            make.centerY.equalTo(radiusView)
        }
    }
    
}
