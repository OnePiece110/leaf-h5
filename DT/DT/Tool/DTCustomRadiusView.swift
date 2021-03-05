//
//  DTCustomRadiusView.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/4.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

class DTCustomRadiusView: UIView {

    var topLeftRadius:CGFloat = 0
    var topRightRadius:CGFloat = 0
    var bottomLeftRadius:CGFloat = 0
    var bottomRightRadius:CGFloat = 0
    var corner:CGFloat = 0 {
        didSet {
            topLeftRadius = corner
            topRightRadius = corner
            bottomLeftRadius = corner
            bottomRightRadius = corner
            setNeedsLayout()
        }
    }
    var topCorner:CGFloat = 0 {
        didSet {
            topLeftRadius = topCorner
            topRightRadius = topCorner
            bottomLeftRadius = 0
            bottomRightRadius = 0
            setNeedsLayout()
        }
    }
    var bottomCorner:CGFloat = 0 {
        didSet {
            topLeftRadius = 0
            topRightRadius = 0
            bottomLeftRadius = bottomCorner
            bottomRightRadius = bottomCorner
            setNeedsLayout()
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = dt_createPath()
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        self.layer.mask = shapeLayer
    }
    
    private func dt_createPath() -> UIBezierPath {
        let topLeftCenterX = self.bounds.minX + topLeftRadius;
        let topLeftCenterY = self.bounds.minY + topLeftRadius;
        
        let topRightCenterX = self.bounds.maxX - topRightRadius;
        let topRightCenterY = self.bounds.minY + topRightRadius;
        
        let bottomLeftCenterX = self.bounds.minX +  bottomLeftRadius;
        let bottomLeftCenterY = self.bounds.maxY - bottomLeftRadius;
        
        let bottomRightCenterX = self.bounds.maxX -  bottomRightRadius;
        let bottomRightCenterY = self.bounds.maxY - bottomRightRadius;
        
        let path = UIBezierPath()
        
        path.addArc(withCenter: CGPoint(x: topLeftCenterX, y: topLeftCenterY), radius: topLeftRadius, startAngle: .pi, endAngle: .pi/2*3, clockwise: true)
        
        path.addArc(withCenter: CGPoint(x: topRightCenterX, y: topRightCenterY), radius: topRightRadius, startAngle: .pi/2*3, endAngle: 0, clockwise: true)
        
        path.addArc(withCenter: CGPoint(x: bottomRightCenterX, y: bottomRightCenterY), radius: bottomRightRadius, startAngle: 0, endAngle: .pi/2, clockwise: true)
        
        path.addArc(withCenter: CGPoint(x: bottomLeftCenterX, y: bottomLeftCenterY), radius: bottomLeftRadius, startAngle: .pi/2, endAngle: .pi, clockwise: true)
        
        path.close()
        return path
    }
    
}
