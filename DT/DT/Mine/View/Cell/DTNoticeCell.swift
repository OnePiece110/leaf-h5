//
//  DTNoticeCell.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/11.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

class DTNoticeCell: DTBaseTableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configSubViews()
    }
    
    func readData(model: DTNoticeItemModel) {
        self.titleLabel.text = model.title
        self.contentLabel.text = model.content
        self.dateLabel.text = model.pubTime
    }
    
    private func configSubViews() {
        self.contentView.addSubview(bgView)
        bgView.addSubview(iconIamgeView)
        bgView.addSubview(titleLabel)
        bgView.addSubview(dateLabel)
        bgView.addSubview(contentLabel)
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 15, bottom: 10, right: 15))
        }
        
        self.iconIamgeView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(20)
            make.size.equalTo(CGSize(width: 11, height: 14))
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(iconIamgeView)
            make.left.equalTo(iconIamgeView.snp.right).offset(5)
            
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.left.greaterThanOrEqualTo(titleLabel.snp.right).offset(15)
            make.centerY.equalTo(titleLabel)
            make.right.equalTo(-15)
        }
        
        contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconIamgeView.snp.bottom).offset(8)
            make.left.equalTo(15)
            make.bottom.right.equalTo(-15)
        }
        
        dateLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .horizontal)
        
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 749), for: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var bgView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = APPColor.colorSubBgView
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 10
        return bgView
    }()
    
    private lazy var iconIamgeView: UIImageView = {
        let iconIamgeView = UIImageView(image: UIImage(named: "icon_mine_notice"))
        return iconIamgeView
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.dt.Bold_Font(16)
        titleLabel.text = "系统通知"
        titleLabel.textColor = APPColor.colorWhite
        return titleLabel
    }()
    
    private lazy var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.font = UIFont.dt.Font(14)
        dateLabel.text = "2020.06.14 18:42"
        dateLabel.textColor = APPColor.colorWhite.withAlphaComponent(0.5)
        return dateLabel
    }()
    
    private lazy var contentLabel: UILabel = {
        let contentLabel = UILabel()
        contentLabel.font = UIFont.dt.Font(14)
        contentLabel.text = "The 1896 Cedar Keys hurricane was a powerful tropical cyclone that devastated much of the East Coast of the United States, starting with Florida's Cedar Keys, near the end of September."
        contentLabel.textColor = APPColor.colorWhite.withAlphaComponent(0.5)
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.numberOfLines = 0
        return contentLabel
    }()
}
