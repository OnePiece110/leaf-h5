//
//  DTMineHeaderView.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/4.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import SnapKit

class DTMineHeaderView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(self.avaterImageView)
        addSubview(self.nickNameLabel)
        addSubview(self.routeNameLabel)
        addSubview(self.dateNameLabel)
        
        avaterImageView.snp.makeConstraints { (make) in
            make.top.equalTo(23)
            make.left.equalTo(15)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }
        
        nickNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(avaterImageView.snp.top)
            make.left.equalTo(avaterImageView.snp.right).offset(15)
            make.right.lessThanOrEqualTo(self.snp.right).offset(-15).priority(999)
            make.height.equalTo(25)
        }
        
        routeNameLabel.snp.makeConstraints { (make) in
            make.height.equalTo(17)
            make.left.equalTo(nickNameLabel.snp.left)
            make.top.equalTo(nickNameLabel.snp.bottom).offset(4)
        }
        
        dateNameLabel.snp.makeConstraints { (make) in
            make.height.equalTo(17)
            make.left.equalTo(routeNameLabel.snp.right).offset(15)
            make.centerY.equalTo(routeNameLabel.snp.centerY)
            make.right.lessThanOrEqualTo(self.snp.right).offset(-15).priority(999)
        }
        
        self.routeNameLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .horizontal)
        self.dateNameLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 749), for: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData() {
        self.nickNameLabel.text = DTUser.sharedUser.isLogin ? DTUser.sharedUser.nickName : "登录/注册"
    }
    
    @objc func avaterImageViewClick() {
        if let vc = DTConstants.currentTopViewController() {
            if vc.dt.theClassName != "DTUserProfileViewController" {
                Router.routeToClass(DTUserProfileViewController.self, params: nil, isCheckLogin: false)
//                Router.routeToClass(DTUserProfileViewController.self, params: nil, isCheckLogin: true)
            }
        }
    }
    
    lazy var avaterImageView: UIImageView = {
        let avaterImageView = UIImageView()
        avaterImageView.image = UIImage(named: "icon_avatar_default")
        avaterImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(avaterImageViewClick))
        avaterImageView.addGestureRecognizer(tap)
        return avaterImageView
    }()
    
    lazy var nickNameLabel: UILabel = {
        let nickNameLabel = UILabel()
        nickNameLabel.text = "登录/注册"
        nickNameLabel.textColor = APPColor.colorWhite
        nickNameLabel.font = UIFont.dt.Bold_Font(18)
        return nickNameLabel
    }()
    
    lazy var routeNameLabel: UILabel = {
        let routeNameLabel = UILabel()
        routeNameLabel.text = "普通路线"
        routeNameLabel.textColor = APPColor.colorWhite
        routeNameLabel.font = UIFont.dt.Font(12)
        return routeNameLabel
    }()
    
    lazy var dateNameLabel: UILabel = {
        let dateNameLabel = UILabel()
        dateNameLabel.text = "2020.12.23 13:42:28 到期"
        dateNameLabel.textColor = APPColor.colorWhite
        dateNameLabel.font = UIFont.dt.Font(12)
        return dateNameLabel
    }()

}
