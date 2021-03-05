//
//  DTAvatarCell.swift
//  DT
//
//  Created by Ye Keyon on 2021/2/12.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit

class DTAvatarCell: DTBaseTableViewCell {

    var model:DTUserProfileRowModel = DTUserProfileRowModel(title: "默认线路设置", type: .bindInvite) {
        didSet {
            radiusView.topLeftRadius = model.topLeftRadius
            radiusView.topRightRadius = model.topRightRadius
            radiusView.bottomLeftRadius = model.bottomLeftRadius
            radiusView.bottomRightRadius = model.bottomRightRadius
            if model.corner > 0 {
                radiusView.corner = model.corner
            }
            titleLabel.text = model.title
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configSubViews()
    }
    
    private func configSubViews() {
        radiusView.backgroundColor = APPColor.colorSubBgView
        self.contentView.addSubview(radiusView)
        radiusView.addSubview(titleLabel)
        radiusView.addSubview(avaterImageView)
        radiusView.addSubview(arrowImageView)
        radiusView.addSubview(lineView)
        
        radiusView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.bottom.equalTo(0)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.contentView)
            make.left.equalTo(15)
        }
        
        arrowImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.width.equalTo(7)
            make.height.equalTo(10)
            make.right.equalTo(-15)
        }
        
        avaterImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.contentView)
            make.size.equalTo(CGSize(width: 50, height: 50))
            make.right.equalTo(-15)
        }
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(0)
            make.height.equalTo(1)
        }
    }
    
    private let radiusView = DTCustomRadiusView()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel().dt
            .font(UIFont.dt.Bold_Font(14))
            .textColor(APPColor.colorWhite)
            .build
        return titleLabel
    }()
    
    private lazy var avaterImageView: UIImageView = {
        let avaterImageView = UIImageView().dt
            .backgroundColor(APPColor.colorWhite)
            .build
        avaterImageView.layer.cornerRadius = 10
        avaterImageView.layer.masksToBounds = true
        return avaterImageView
    }()
    
    private lazy var lineView: UIView = {
        let lineView = UIView().dt
            .backgroundColor(APPColor.color235476)
            .build
        return lineView
    }()
    
    private lazy var arrowImageView:UIImageView = {
        let image = UIImage(named: "icon_link_button_arrow")?.withRenderingMode(.alwaysTemplate)
        let arrowImageView = UIImageView(image: image)
        arrowImageView.tintColor = .white
        return arrowImageView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
