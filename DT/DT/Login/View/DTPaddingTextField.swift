//
//  DTPaddingTextField.swift
//  DT
//
//  Created by Ye Keyon on 2021/2/11.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit

class DTPaddingTextField: UIView {

    init(padding: CGFloat) {
        super.init(frame: .zero)
        self.backgroundColor = APPColor.colorSubBgView
        addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var placeholder: String = "" {
        didSet {
            textField.attributedPlaceholder = placeholder.font(UIFont.dt.Font(14)).color(APPColor.colorWhite.withAlphaComponent(0.3))
        }
    }
    
    lazy var textField: UITextField = {
        let textField = UITextField().dt
            .font(UIFont.dt.Font(14))
            .textColor(APPColor.colorWhite)
            .attributedPlaceholder("请输入验证码".font(UIFont.dt.Font(14)).color(APPColor.colorWhite.withAlphaComponent(0.3)))
            .build
        return textField
    }()

}
