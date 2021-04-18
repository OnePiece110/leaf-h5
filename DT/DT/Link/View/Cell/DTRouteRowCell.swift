//
//  DTRouteRowCell.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/18.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

class DTRouteRowCell: DTBaseTableViewCell {

    private let radiusView = DTCustomRadiusView()
    private var ping: SwiftyPing?
    
    private var model:DTServerVOItemData = DTServerVOItemData()  {
        didSet {
            titleLabel.text = model.name
            iconImageView.image = UIImage(named: model.area.lowercased())
            if let selectRouter = DTUserDefaults?.object(forKey: DTSelectRouter) as? String {
                if !selectRouter.isVaildEmpty() {
                    if let selectRouterData = selectRouter.kj.model(DTServerVOItemData.self) {
                        connectButton.isSelected = (selectRouterData.itemId == model.itemId)
                    } else {
                        connectButton.isSelected = false
                    }
                } else {
                    connectButton.isSelected = false
                }
            } else {
                connectButton.isSelected = false
            }
            
            if model.ping > 0 {
                if model.ping <= 200 {
                    self.rateLabel.text = "超快"
                    self.rateLabel.textColor = APPColor.color00B170
                    self.rateImageView.image = UIImage(named: "icon_link_rate_very_fast")
                } else if (model.ping >= 200 && model.ping <= 500) {
                    self.rateLabel.text = "快"
                    self.rateLabel.textColor = APPColor.sub
                    self.rateImageView.image = UIImage(named: "icon_link_rate_fast")
                } else {
                    self.rateLabel.text = "一般"
                    self.rateLabel.textColor = APPColor.colorError
                    self.rateImageView.image = UIImage(named: "icon_link_rate_general")
                }
            } else {
                self.rateLabel.text = nil;
                self.rateImageView.image = nil;
            }
            
            connectButton.backgroundColor = connectButton.isSelected ? UIColor.clear : APPColor.colorD8D8D8.withAlphaComponent(0.1)
        }
    }
    
    func readData(model: DTServerVOItemData, currentIndex: Int, count: Int) {
        self.model = model
        if currentIndex == count - 1 {
            radiusView.bottomCorner = 10
        } else {
            radiusView.corner = 0
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
        radiusView.addSubview(self.rateLabel)
        radiusView.addSubview(self.rateImageView)
        radiusView.addSubview(lineView)
        radiusView.addSubview(self.connectButton)
        
        radiusView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        }
        
        self.iconImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(radiusView)
            make.left.equalTo(15)
            make.size.equalTo(CGSize(width: 36, height: 24))
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(radiusView)
            make.height.equalTo(20)
            make.left.equalTo(self.iconImageView.snp.right).offset(10)
            make.right.equalTo(self.rateImageView.snp.left).offset(-10)
        }
        
        self.rateImageView.snp.makeConstraints { (make) in
            make.right.equalTo(-124)
            make.size.equalTo(CGSize(width: 18, height: 16))
            make.centerY.equalTo(self.contentView)
        }
        
        self.rateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.rateImageView.snp.right).offset(5)
            make.centerY.equalTo(self.contentView)
        }
        
        self.lineView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-1)
            make.height.equalTo(1)
        }
        
        self.connectButton.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.size.equalTo(CGSize(width: 70, height: 30))
            make.centerY.equalTo(self.radiusView)
        }
        
    }
    
    private lazy var iconImageView:UIImageView = {
        let iconImageView = UIImageView()
        iconImageView.clipsToBounds = true
        return iconImageView
    }()
    
    private lazy var titleLabel:UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.dt.Font(14)
        titleLabel.textColor = APPColor.colorF6F6F6
        return titleLabel
    }()
    
    private lazy var rateLabel:UILabel = {
        let rateLabel = UILabel()
        rateLabel.font = UIFont.dt.Font(12)
        rateLabel.textColor = APPColor.color00B170
        return rateLabel
    }()
    
    private lazy var rateImageView: UIImageView = {
        let rateImageView = UIImageView()
        return rateImageView
    }()
    
    private lazy var lineView:UIView = {
        let lineView = UIView()
        lineView.backgroundColor = APPColor.color235476
        return lineView
    }()
    
    private lazy var connectButton:UIButton = {
        let connectButton = UIButton(type: .custom)
        connectButton.isUserInteractionEnabled = false
        connectButton.layer.cornerRadius = 15
        connectButton.layer.masksToBounds = true
        connectButton.titleLabel?.font = UIFont.dt.Bold_Font(14)
        connectButton.backgroundColor = APPColor.colorD8D8D8.withAlphaComponent(0.1)
        
        connectButton.setTitle("连接", for: .normal)
        connectButton.setTitleColor(.white, for: .normal)
        connectButton.setBackgroundImage(nil, for: .selected)
        
        connectButton.setTitle("", for: .selected)
        connectButton.setBackgroundImage(UIImage(named: "icon_common_select"), for: .selected)
        return connectButton
    }()
}
