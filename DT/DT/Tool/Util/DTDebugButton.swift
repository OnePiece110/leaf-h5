//
//  DTDebugButton.swift
//  DT
//
//  Created by Ye Keyon on 2021/4/14.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit

class DTDebugButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.blue.withAlphaComponent(0.7);
        self.layer.cornerRadius = frame.height/2;
        self.layer.masksToBounds = true;
        self.titleLabel?.font = UIFont.dt.Font(14);
        self.setTitleColor(.white, for: .normal)
        self.setTitle("工具", for: .normal)
        self.addTarget(self, action: #selector(debugButtonClick), for: .touchUpInside)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(move(pan:)))
        self.addGestureRecognizer(pan)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func debugButtonClick() {
        Router.routeToClass(DTToolViewController.self)
    }
    
    @objc private func move(pan: UIPanGestureRecognizer) {
        if (pan.state == .changed) {
            let point = pan.translation(in: self.superview);
            
            if let superview = self.superview  {
                var centerX = self.center.x + point.x;
                var centerY = self.center.y + point.y;
                let left = self.frame.size.width / 2.0;
                let right = superview.frame.width - self.frame.width / 2.0;
                let top = APPSystem.kTopLayoutGuideHeight + self.frame.height / 2.0;
                let bottom = superview.frame.height - self.frame.height / 2.0;
                if (centerX < left) {
                    centerX = left;
                }
                if (centerX > right) {
                    centerX = right;
                }
                if (centerY < top) {
                    centerY = top;
                }
                if (centerY > bottom) {
                    centerY = bottom;
                }
                self.center = CGPoint(x: centerX, y: centerY);
                pan.setTranslation(.zero, in: self.superview)
            }
            
        }
    }
}
