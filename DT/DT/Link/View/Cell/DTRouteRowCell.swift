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
    
    lazy var iconImageView:UIImageView = {
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.layer.cornerRadius = 17
        iconImageView.layer.masksToBounds = true
        return iconImageView
    }()
    
    lazy var titleLabel:UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.dt.Font(14)
        titleLabel.textColor = APPColor.colorF6F6F6
        return titleLabel
    }()
    
    lazy var rateLabel:UILabel = {
        let rateLabel = UILabel()
        rateLabel.font = UIFont.dt.Font(12)
        rateLabel.textColor = UIColor.dt.hex("26CF5E")
        return rateLabel
    }()
    
    lazy var lineView:UIView = {
        let lineView = UIView()
        lineView.backgroundColor = APPColor.color235476
        return lineView
    }()
    
    lazy var connectButton:UIButton = {
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
//        connectButton.addTarget(self, action: #selector(connectButtonClick), for: .touchUpInside)
        return connectButton
    }()
    
    private var model:DTServerVOItemData = DTServerVOItemData()  {
        didSet {
            titleLabel.text = model.name
            rateLabel.textColor = UIColor.dt.hex(model.color)
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
        radiusView.addSubview(lineView)
        radiusView.addSubview(self.connectButton)
        
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
            make.height.equalTo(20)
            make.left.equalTo(self.iconImageView.snp.right).offset(15)
        }
        
        self.rateLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.connectButton.snp.left).offset(-15)
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
    
}
