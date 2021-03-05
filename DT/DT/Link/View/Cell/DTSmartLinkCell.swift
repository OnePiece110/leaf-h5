//
//  DTSmartLinkCell.swift
//  DT
//
//  Created by Ye Keyon on 2021/1/17.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit

class DTSmartLinkCell: DTBaseTableViewCell {

    private let radiusView = DTCustomRadiusView()
    
    lazy var titleLabel:UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.dt.Bold_Font(16)
        titleLabel.textColor = APPColor.colorF6F6F6
        return titleLabel
    }()
    
    lazy var descLabel:UILabel = {
        let descLabel = UILabel()
        descLabel.font = UIFont.dt.Font(14)
        descLabel.textColor = APPColor.colorF6F6F6.withAlphaComponent(0.5)
        return descLabel
    }()
    
    lazy var connectButton:UIButton = {
        let connectButton = UIButton(type: .custom)
        connectButton.isUserInteractionEnabled = false
        connectButton.layer.cornerRadius = 15
        connectButton.layer.masksToBounds = true
        connectButton.backgroundColor = APPColor.colorD8D8D8.withAlphaComponent(0.1)
        connectButton.setBackgroundImage(UIImage(named: "icon_common_unselect"), for: .normal)
        connectButton.setBackgroundImage(UIImage(named: "icon_common_select"), for: .selected)
        return connectButton
    }()
    
    var model:DTServerGroupData = DTServerGroupData()  {
        didSet {
            titleLabel.text = model.groupName
            descLabel.text = model.groupDescription
            if let selectRouter = DTUserDefaults?.object(forKey: DTSelectRouter) as? String {
                if !selectRouter.isVaildEmpty() {
                    if let selectRouterData = selectRouter.kj.model(DTServerGroupData.self) {
                        connectButton.isSelected = (selectRouterData.groupId == model.groupId)
                    } else {
                        connectButton.isSelected = false
                    }
                } else {
                    connectButton.isSelected = false
                }
            } else {
                connectButton.isSelected = false
            }
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
        radiusView.addSubview(self.titleLabel)
        radiusView.addSubview(self.descLabel)
        radiusView.addSubview(self.connectButton)
        
        radiusView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(15)
            make.height.equalTo(22)
        }
        
        self.descLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.titleLabel.snp.left)
            make.top.equalTo(self.titleLabel.snp.bottom)
        }
        
        self.connectButton.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.size.equalTo(CGSize(width: 70, height: 30))
            make.centerY.equalTo(self.radiusView)
        }
        
    }
    
    
}
