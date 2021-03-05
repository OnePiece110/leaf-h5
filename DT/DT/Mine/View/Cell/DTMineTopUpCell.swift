//
//  DTMineTopUpCell.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/12.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

protocol DTMineTopUpCellDelegate:class {
    func advertisementCloseClick()
}

class DTMineTopUpCell: DTBaseTableViewCell {

    private let radiusView = DTCustomRadiusView()
    weak var delegate: DTMineTopUpCellDelegate?
    private lazy var titleLabel:UILabel = {
       let titleLabel = UILabel()
        titleLabel.font = UIFont.dt.Font(12)
        titleLabel.textColor = .white
        return titleLabel
    }()
    
    private lazy var descLabel:UILabel = {
       let descLabel = UILabel()
        descLabel.font = UIFont.dt.Bold_Font(18)
        descLabel.text = "智能模式（推荐）"
        descLabel.textColor = .white
        return descLabel
    }()
    
    private lazy var arrowImageView:UIImageView = {
        let image = UIImage(named: "icon_common_close")?.withRenderingMode(.alwaysTemplate)
        let arrowImageView = UIImageView(image: image)
        arrowImageView.tintColor = .white
        arrowImageView.isUserInteractionEnabled = true
        return arrowImageView
    }()
    
    var model:DTMineRowModel = DTMineRowModel(title: "常见问题", iconName: "icon_mine_question", type: .advertisement) {
        didSet {
            titleLabel.text = model.title
            descLabel.text = model.descText
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        configureSubView()
        configAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func closeClick() {
        delegate?.advertisementCloseClick()
    }
    
    private func configureSubView() {
        radiusView.frame = CGRect(x: 0, y: 0, width: kScreentWidth - 20, height: 62)
        radiusView.dt.addGradient(GradientLayer(direction: .topToBottom, colors: [APPColor.color26B3AD,APPColor.color09598B]))
        radiusView.corner = 10
        self.contentView.addSubview(radiusView)
        radiusView.addSubview(descLabel)
        radiusView.addSubview(titleLabel)
        radiusView.addSubview(arrowImageView)
        
        radiusView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.bottom.equalTo(0)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(10)
        }
        
        arrowImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(radiusView)
            make.width.height.equalTo(13)
            make.right.equalTo(-15)
        }
        
        descLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(-10)
            make.left.equalTo(titleLabel.snp.left)
        }
    }
    
    func configAction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeClick))
        arrowImageView.addGestureRecognizer(tap)
    }

}
