//
//  DTFeedbackCell.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/28.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

protocol DTFeedbackCellDelegate:class {
    func closeButtonClick(cell: DTFeedbackCell)
}

class DTFeedbackCell: UICollectionViewCell {
    
    weak var delegate:DTFeedbackCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubViews()
        self.closeButton.addTarget(self, action: #selector(closeButtonClick), for: .touchUpInside)
    }
    
    @objc func closeButtonClick() {
        delegate?.closeButtonClick(cell: self)
    }
    
    func readData(_ data: DTFeedbackModel) {
        if data.type == .add {
            self.contentImageView.image = nil
            self.addImageView.image = #imageLiteral(resourceName: "icon_feedback_add")
            closeButton.isHidden = true
        } else {
            self.contentImageView.image = data.image
            self.addImageView.image = nil
            closeButton.isHidden = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubViews() {
        self.contentView.addSubview(self.contentImageView)
        self.contentView.addSubview(self.addImageView)
        self.contentView.addSubview(self.closeButton)
        
        self.contentImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        self.addImageView.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(self.contentView)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        self.closeButton.snp.makeConstraints { (make) in
            make.top.right.equalTo(0)
        }
    }
    
    lazy var contentImageView:UIImageView = {
        let contentImageView = UIImageView()
        contentImageView.backgroundColor = APPColor.color26344F
        contentImageView.layer.cornerRadius = 13
        contentImageView.layer.masksToBounds = true
        contentImageView.contentMode = .scaleAspectFill
        return contentImageView
    }()
    
    lazy var addImageView:UIImageView = {
        let addImageView = UIImageView(image: #imageLiteral(resourceName: "icon_feedback_add"))
        return addImageView
    }()
    
    lazy var closeButton:UIButton = {
        let closeButton = UIButton(type: .custom)
        closeButton.setImage(#imageLiteral(resourceName: "icon_feedback_delete"), for: .normal)
        return closeButton
    }()
}
