//
//  DTRippleView.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/18.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import SnapKit

protocol DTRippleViewDelegate:class {
    func rippleViewClick()
}

enum DTRippleViewType {
    case initial
    case good
    case general
    case bad
}

class DTRippleView: UIView {

    private var items = [CALayer]()
    weak var animationLayer: CALayer?
    weak var delegate: DTRippleViewDelegate?
    var isAnimation = false
    private var iconImageView = UIImageView(image: UIImage(named: "icon_link_unLink"))
    private var animateColor = UIColor.white
    
    lazy var titleLabel:UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.dt.Bold_Font(16)
        titleLabel.textColor = APPColor.colorWhite
        titleLabel.text = "点击连接"
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(rippleAction))
        self.addGestureRecognizer(tap)
        
        self.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        self.addSubview(self.titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.bottom.equalTo(-27)
        }
    }
    
    @objc func rippleAction() {
        if self.isAnimation {
            self.stopAnimation()
        } else {
            self.startAnimation()
        }
        delegate?.rippleViewClick()
    }
    
    func resetPulsingColor(type: DTRippleViewType) {
        var image: UIImage?
        var color: UIColor = .white
        switch type {
        case .good:
            image = UIImage(named: "icon_link_good")
            color = APPColor.color00B170
        case .general:
            image = UIImage(named: "icon_link_general")
            color = APPColor.sub
        case .bad:
            image = UIImage(named: "icon_link_bad")
            color = APPColor.colorError
        case .initial:
            image = UIImage(named: "icon_link_unLink")
            color = APPColor.color52AAAA
        }
        iconImageView.image = image
        animateColor = color
        for item in self.items {
            item.borderColor = color.cgColor
        }
    }
    
    

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func startAnimation() {
        let pulsingCount = 4
        let animationDuration: Double = 2.5
        self.isAnimation = true
        let animationLayer = CALayer()
        for i in 0..<pulsingCount {
            let pulsingLayer = CALayer()
            pulsingLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
            pulsingLayer.borderColor = animateColor.cgColor
            pulsingLayer.borderWidth = 1
            pulsingLayer.cornerRadius = 112.5
            
            let defaultCurve = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
            
            let animationGroup = CAAnimationGroup()
            animationGroup.fillMode = CAMediaTimingFillMode.backwards
            animationGroup.beginTime = CACurrentMediaTime() + Double(i) * animationDuration / Double(pulsingCount)
            animationGroup.duration = animationDuration
            animationGroup.repeatCount = HUGE
            animationGroup.timingFunction = defaultCurve
            animationGroup.isRemovedOnCompletion = false
            
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = 1
            scaleAnimation.toValue = 1.27
            
            let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
            opacityAnimation.values = [1,0.7,0]
            opacityAnimation.keyTimes = [0,0.5,1]
            
            animationGroup.animations = [scaleAnimation,opacityAnimation]
            
            pulsingLayer.add(animationGroup, forKey: "pulsing")
            animationLayer.addSublayer(pulsingLayer)
            items.append(pulsingLayer)
        }
        self.layer.addSublayer(animationLayer)
        self.animationLayer = animationLayer
    }
    
    @objc func stopAnimation() {
        self.isAnimation = false
        for item in self.items {
            item.removeAllAnimations()
            item.removeFromSuperlayer()
        }
        self.items.removeAll()
        self.animationLayer?.removeFromSuperlayer()
    }

}
