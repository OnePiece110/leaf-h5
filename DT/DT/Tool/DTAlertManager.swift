//
//  MSAlertManager.swift
//  Miaosu
//
//  Created by 叶金永 on 2019/1/27.
//  Copyright © 2019 Keyon. All rights reserved.
//

import UIKit
import SnapKit

enum animationType {
	case scale
	case bottomToTop
}

class DTAlertManager: NSObject,UIGestureRecognizerDelegate {
	
    //是否全屏
    var isFull = false
	private weak var view:UIView!
	private var type:animationType!
	var isDimissTapBgView:Bool = true
	private var bgView = UIView()
	private let kAnimationKey_FadeInAlertViewScale = "AnimationKey_FadeInAlertViewScale";
	private let kAnimationKey_FadeOutAlertViewScale = "AnimationKey_FadeOutAlertViewScale";
	private let kAnimationKey_FadeInAlertViewPositionY = "AnimationKey_FadeInAlertViewPositionY";
	private let kAnimationKey_FadeOutAlertViewPositionY = "AnimationKey_FadeOutAlertViewPositionY";
	private let scaleAniamtionDuration:CFTimeInterval = 0.3
	init(_ view:UIView, type:animationType = .scale, isDimissTapBgView:Bool = true, cornerRadius:CGFloat = 10) {
		super.init()
		self.view = view
		self.type = type
		self.view.layer.cornerRadius = cornerRadius
		self.view.layer.masksToBounds = true
		self.isDimissTapBgView = isDimissTapBgView
        self.bgView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(removeView))
        self.bgView.addGestureRecognizer(tap)
        tap.delegate = self
	}
	
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view {
            if view != self.bgView {
                return false
            }
        }
        return true
    }
    
	func show() {
        let window = UIApplication.dt.currentWindow()
		if let window = window {
			
			self.bgView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
			self.bgView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            
			window.addSubview(self.bgView)
			self.bgView.addSubview(self.view)
			if self.type == .scale {
                self.view.snp.makeConstraints { (make) in
                    make.centerX.centerY.equalTo(self.bgView)
                    make.left.greaterThanOrEqualTo(25)
                    make.right.lessThanOrEqualTo(-25)
                }
				
				let keyFrameAnimation = CAKeyframeAnimation()
				keyFrameAnimation.delegate = self
				keyFrameAnimation.keyPath = "transform.scale"
				keyFrameAnimation.values = [0.02, 1.1, 0.95, 1.0];
				keyFrameAnimation.duration = scaleAniamtionDuration
				keyFrameAnimation.isRemovedOnCompletion = false;
				keyFrameAnimation.fillMode = CAMediaTimingFillMode.forwards;
				self.view.layer.add(keyFrameAnimation, forKey: kAnimationKey_FadeInAlertViewScale)
			} else if self.type == .bottomToTop {
                if isFull {
                    self.view.snp.makeConstraints { (make) in
                        make.edges.equalTo(0)
                    }
                } else {
                    self.view.snp.makeConstraints { (make) in
                        make.left.right.bottom.equalTo(0)
                    }
                }
				
				let keyFrameAnimation = CAKeyframeAnimation()
				keyFrameAnimation.delegate = self
				keyFrameAnimation.keyPath = "position.y"
				keyFrameAnimation.values = [self.view.layer.position.y + screenHeight, screenHeight - self.view.layer.position.y];
				keyFrameAnimation.duration = scaleAniamtionDuration
				keyFrameAnimation.isRemovedOnCompletion = false;
				keyFrameAnimation.fillMode = CAMediaTimingFillMode.forwards;
				self.view.layer.add(keyFrameAnimation, forKey: kAnimationKey_FadeInAlertViewPositionY)
			}
			
		}
	}
	
	func dimiss() {
        let window = UIApplication.dt.currentWindow()
		if let window = window {
			if self.type == .scale {
				let keyFrameAnimation = CAKeyframeAnimation()
				keyFrameAnimation.delegate = self
				keyFrameAnimation.keyPath = "transform.scale"
				keyFrameAnimation.values = [1, 0.95, 1.1, 0.02];
				keyFrameAnimation.duration = scaleAniamtionDuration
				keyFrameAnimation.isRemovedOnCompletion = false;
				keyFrameAnimation.fillMode = CAMediaTimingFillMode.forwards;
				self.view.layer.add(keyFrameAnimation, forKey: kAnimationKey_FadeOutAlertViewScale)
			} else if self.type == .bottomToTop {
				var size:CGSize!
				var offset:CGFloat = 0
				if #available(iOS 11.0, *) {
					size = CGSize(width: self.view.frame.width, height: self.view.frame.height + window.safeAreaInsets.bottom)
					offset = window.safeAreaInsets.bottom
				} else {
					size = self.view.frame.size
				}
				let keyFrameAnimation = CAKeyframeAnimation()
				keyFrameAnimation.delegate = self
				keyFrameAnimation.keyPath = "position.y"
				keyFrameAnimation.values = [self.view.layer.position.y + offset, self.view.layer.position.y + size.height];
				keyFrameAnimation.duration = scaleAniamtionDuration
				keyFrameAnimation.isRemovedOnCompletion = false;
				keyFrameAnimation.fillMode = CAMediaTimingFillMode.forwards;
				self.view.layer.add(keyFrameAnimation, forKey: kAnimationKey_FadeOutAlertViewPositionY)
			}
		}
	}
	
	@objc func removeView() {
        if self.isDimissTapBgView {
            self.bgView.removeFromSuperview()
            self.view.removeFromSuperview()
        }
	}
}


extension DTAlertManager:CAAnimationDelegate {
	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		if self.type == .scale {
			let keyFrameAnimation = self.view.layer.animation(forKey: kAnimationKey_FadeOutAlertViewScale)
			if let keyFrameAnimation = keyFrameAnimation {
				if keyFrameAnimation == anim {
					self.view.removeFromSuperview()
					self.bgView.removeFromSuperview()
					self.view = nil
				}
			}
		} else if self.type == .bottomToTop {
			let keyFrameAnimation = self.view.layer.animation(forKey: kAnimationKey_FadeOutAlertViewPositionY)
			if let keyFrameAnimation = keyFrameAnimation {
				if keyFrameAnimation == anim {
					self.view.removeFromSuperview()
					self.bgView.removeFromSuperview()
					self.view = nil
				}
			}
		}
		
	}
}
