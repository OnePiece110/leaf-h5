//
//  DTImageTitleButton.swift
//  DT
//
//  Created by Ye Keyon on 2021/2/11.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit

enum DTImageTitleButtonState: String {
    case normal
    case select
}

class DTImageTitleButton: UIView {

    private var space:CGFloat = 5 {
        didSet {
            titleLabel.snp.updateConstraints { (make) in
                make.left.equalTo(iconImageView.snp.right).offset(space)
            }
        }
    }
    private var title: String = "显示"
    private var iconDic = [String: UIImage]()
    private var titleDic = [String: String]()
    
    var state: DTImageTitleButtonState = .normal {
        didSet {
            titleLabel.text = titleDic[state.rawValue]
            iconImageView.image = iconDic[state.rawValue]
        }
    }
    
    init(space: CGFloat) {
        super.init(frame: .zero)
        self.space = space
        configSubView()
        
    }
    
    private func configSubView() {
        addSubview(iconImageView)
        addSubview(titleLabel)
        
        iconImageView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.size.equalTo(CGSize(width: 21, height: 14))
            make.centerY.equalTo(self)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconImageView.snp.right).offset(space)
            make.top.bottom.right.equalTo(0)
            make.height.equalTo(20)
        }
    }
    
    func setTitle(_ title: String, state: DTImageTitleButtonState) {
        titleDic[state.rawValue] = title
        if state == self.state {
            titleLabel.text = title
        }
    }
    
    func setImage(_ image: UIImage?, state: DTImageTitleButtonState) {
        if let image = image {
            iconDic[state.rawValue] = image
        } else {
            
        }
        
        if state == self.state {
            iconImageView.image = image
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var iconImageView: UIImageView = {
        let iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFill
        return iconImageView
    }()
    
    private var titleLabel: UILabel = {
        let titleLabel = UILabel().dt
            .font(UIFont.dt.Font(14))
            .textColor(APPColor.colorWhite)
            .build
        return titleLabel
    }()
    
}
