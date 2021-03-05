//
//  DTTextFieldView.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/12.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

protocol DTTextFieldViewDelegate:class {
    func selectCountryClick()
}

class DTTextFieldView: UIView {
    
    weak var delegate: DTTextFieldViewDelegate?
    
    init(iconName:String,placeHolder:String,isSecureTextEntry:Bool = false) {
        super.init(frame: .zero)
        configureSubViews(leftWidth: 57)
        self.resetIsHidden(isHidden: true)
        self.iconName = iconName
        self.placeHolder = placeHolder
        self.textFied.isSecureTextEntry = isSecureTextEntry
    }
    
    init(code:String,placeHolder:String, isAddTap: Bool = false, corner:CGFloat = 10) {
        super.init(frame: .zero)
        configureSubViews(leftWidth: 142, isShowLine: true, corner: corner)
        self.resetIsHidden(isHidden: false)
        self.code = code
        self.placeHolder = placeHolder
        if isAddTap {
            let tap = UITapGestureRecognizer(target: self, action: #selector(selectCountryClick))
            self.titleLabel.addGestureRecognizer(tap)
        }
    }
    
    @objc func selectCountryClick() {
        self.delegate?.selectCountryClick()
    }
    
    func resetIsHidden(isHidden:Bool) {
        self.titleLabel.isHidden = isHidden
        self.iconImageView.isHidden = !isHidden
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureSubViews(leftWidth: CGFloat, isShowLine: Bool = false, corner:CGFloat = 10) {
        radiusView.backgroundColor = APPColor.color3E5E77
        radiusView.corner = corner
        self.addSubview(radiusView)
        radiusView.addSubview(leftView)
        leftView.addSubview(titleLabel)
        leftView.addSubview(iconImageView)
        radiusView.addSubview(textFied)
        
        radiusView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        leftView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(0)
            make.width.equalTo(leftWidth)
        }
        
        iconImageView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalTo(leftView)
            make.size.equalTo(CGSize(width: 22, height: 22))
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.bottom.equalTo(0)
            make.right.equalTo(-15)
        }
        
        textFied.snp.makeConstraints { (make) in
            make.top.right.bottom.equalTo(0)
            make.left.equalTo(leftView.snp.right)
        }
        
        if isShowLine {
            let lineView = UIView().dt.backgroundColor(APPColor.color235476).build
            self.addSubview(lineView)
            lineView.snp.makeConstraints { (make) in
                make.left.equalTo(15)
                make.height.equalTo(1)
                make.right.equalTo(-15)
                make.bottom.equalTo(0)
            }
        }
    }
    
    //MARK -- UI
    lazy var radiusView = DTCustomRadiusView()
    private lazy var leftView = UIView()
    private lazy var iconImageView = UIImageView()
    
    private var _iconName = ""
    var iconName:String {
        get {
            return _iconName
        }
        set {
            _iconName = newValue
            resetIsHidden(isHidden: true)
            iconImageView.image = UIImage(named: newValue)
        }
    }
    
    private var _code = ""
    var code:String {
        get {
            return _code
        }
        set {
            _code = newValue
            resetIsHidden(isHidden: false)
            self.titleLabel.text = newValue
        }
    }
    
    private var _placeHolder = ""
    var placeHolder:String {
        get {
            return _placeHolder
        }
        set {
            _placeHolder = newValue
            textFied.attributedPlaceholder = _placeHolder.font(UIFont.dt.Font(14)).color(APPColor.colorWhite.withAlphaComponent(0.3))
        }
    }
    
    lazy var titleLabel:UILabel = {
        let titleLabel = UILabel().dt
            .font(UIFont.dt.Font(14))
            .textColor(APPColor.colorWhite)
            .isUserInteractionEnabled(true)
            .build
        return titleLabel
    }()
    
    lazy var textFied:UITextField = {
        let textFied = UITextField().dt
            .font(UIFont.dt.Font(14))
            .textColor(APPColor.colorWhite)
            .borderStyle(.none)
            .build
        return textFied
    }()
}
