//
//  DTCutDownTextField.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/12.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

protocol DTCutDownTextFieldDelegate:class {
    func countDownClick()
}

class DTCutDownTextField: UIView {

    weak var delegate:DTCutDownTextFieldDelegate?
    
    init(iconName:String,placeHolder:String) {
        super.init(frame: .zero)
        configureSubViews()
        self.iconName = iconName
        self.placeHolder = placeHolder
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startCutDownAction() {
        self.codeView.startCutDownAction()
    }
    
    private func configureSubViews() {
        radiusView.backgroundColor = APPColor.color3E5E77
        radiusView.corner = 10
        self.addSubview(radiusView)
        radiusView.addSubview(leftView)
        leftView.addSubview(titleLabel)
        leftView.addSubview(iconImageView)
        radiusView.addSubview(textFied)
        self.addSubview(codeView)
        
        radiusView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(0)
            make.right.equalTo(-127)
        }
        
        leftView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(0)
            make.width.equalTo(57)
        }
        
        iconImageView.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(leftView)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(leftView)
        }
        
        textFied.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(0)
            make.right.equalTo(codeView.snp.left).offset(-10)
            make.left.equalTo(leftView.snp.right)
        }
        
        codeView.snp.makeConstraints { (make) in
            make.top.right.bottom.equalTo(0)
            make.width.equalTo(117)
        }
    }

    //MARK: --UI
    private lazy var radiusView = DTCustomRadiusView()
    private lazy var leftView = UIView()
    private lazy var iconImageView = UIImageView()
    
    private lazy var codeView: DTCutDownView = {
        let codeView = DTCutDownView(frame: .zero)
        codeView.layer.cornerRadius = 22
        codeView.layer.masksToBounds = true
        codeView.delegate = self
        return codeView
    }()
    
    private lazy var titleLabel:UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.dt.Bold_Font(12)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.4)
        return titleLabel
    }()
    
    lazy var textFied:UITextField = {
       let textFied = UITextField()
        textFied.font = UIFont.dt.Bold_Font(14)
        textFied.textColor = .white
        textFied.borderStyle = .none
        return textFied
    }()
    
    private var _iconName = ""
    var iconName:String {
        get {
            return _iconName
        }
        set {
            _iconName = newValue
            iconImageView.image = UIImage(named: newValue)
        }
    }
    
    private var _placeHolder = ""
    var placeHolder:String {
        get {
            return _placeHolder
        }
        set {
            _placeHolder = newValue
            textFied.attributedPlaceholder = placeHolder.font(UIFont.dt.Bold_Font(14)).color(UIColor.white.withAlphaComponent(0.2))
        }
    }
}

extension DTCutDownTextField: DTCutDownViewDelegate {
    func startCutDown() {
        self.delegate?.countDownClick()
    }
}
