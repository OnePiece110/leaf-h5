//
//  DTCountryCell.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/25.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

class DTCountryCell: DTBaseTableViewCell {
    
   var customRadiusView = DTCustomRadiusView()
    
    var nameLabel:UILabel = {
        let nameLabel = UILabel()
        nameLabel.textColor = .white
        nameLabel.text = "中国"
        nameLabel.font = UIFont.dt.Bold_Font(16)
        return nameLabel
    }()
    
    var codeLabel:UILabel = {
        let codeLabel = UILabel()
        codeLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        codeLabel.text = "+86"
        codeLabel.font = UIFont.dt.Bold_Font(16)
        return codeLabel
    }()
    
    private lazy var arrowImageView:UIImageView = {
        let image = UIImage(named: "icon_link_button_arrow")?.withRenderingMode(.alwaysTemplate)
        let arrowImageView = UIImageView(image: image)
        arrowImageView.tintColor = .white
        return arrowImageView
    }()
    
    private var model:DTCountryItemModel = DTCountryItemModel() {
        didSet {
            self.nameLabel.text = model.name
            self.codeLabel.text = model.areaCode
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureSubViews()
    }
    
    func readData(model: DTCountryItemModel, indexPath: IndexPath, count: Int) {
        if indexPath.row == 0 {
            customRadiusView.topCorner = 10
        } else if indexPath.row == count - 1 {
            customRadiusView.bottomCorner = 10
        } else {
            customRadiusView.corner = 0
        }
        self.model = model
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubViews() {
        self.contentView.addSubview(self.customRadiusView)
        self.customRadiusView.addSubview(self.nameLabel)
        self.customRadiusView.addSubview(self.codeLabel)
        self.customRadiusView.addSubview(self.arrowImageView)
        
        self.customRadiusView.backgroundColor = APPColor.colorSubBgView
        
        self.customRadiusView.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        }
        
        self.nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.customRadiusView.snp.left).offset(15)
            make.centerY.equalTo(self.customRadiusView)
            
        }
        
        self.codeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.nameLabel.snp.right).offset(15)
            make.centerY.equalTo(self.customRadiusView)
            make.right.lessThanOrEqualTo(self.arrowImageView.snp.left).offset(-15)
        }
        
        self.arrowImageView.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.centerY.equalTo(self.customRadiusView)
            make.size.equalTo(CGSize(width: 7, height: 10))
        }
        
        self.codeLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 749), for: .horizontal)
        self.arrowImageView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .horizontal)
    }
}
