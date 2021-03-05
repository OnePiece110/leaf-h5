//
//  DTLoginProfileView.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/12.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import SnapKit

class DTLoginProfileView: UIView {
    
    init(title:String) {
        super.init(frame: .zero)
        configureSubViews()
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubViews() {
        self.addSubview(titleLabel)
        self.addSubview(errorLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(0)
        }
        
        errorLabel.snp.makeConstraints { (make) in
            make.top.right.bottom.equalTo(0)
        }
    }
    
    //MARK: --UI
    lazy var titleLabel:UILabel = {
        let titleLabel = UILabel().dt
            .font(UIFont.dt.Font(14))
            .textColor(APPColor.colorWhite)
            .build
        return titleLabel
    }()
    
    lazy var errorLabel:UILabel = {
        let errorLabel = UILabel().dt
            .font(UIFont.dt.Bold_Font(14))
            .textColor(APPColor.colorError)
            .build
        return errorLabel
    }()
    
    private var _title = ""
    var title:String {
        get {
            return _title
        }
        set {
            _title = newValue
            self.titleLabel.text = newValue
        }
    }
}
