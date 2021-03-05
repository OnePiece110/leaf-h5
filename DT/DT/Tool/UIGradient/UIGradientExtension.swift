//
//  UIGradientExtension.swift
//  UIGradient
//
//  Created by Dinh Quang Hieu on 12/7/17.
//  Copyright © 2017 Dinh Quang Hieu. All rights reserved.
//

import UIKit

public extension DengTa where Base: UIView {
    
    func addGradientWithDirection(_ direction: GradientDirection, colors: [UIColor], cornerRadius: CGFloat = 0, locations: [Double]? = nil) {
        let gradientLayer = GradientLayer(direction: direction, colors: colors, cornerRadius: cornerRadius, locations: locations)
        self.addGradient(gradientLayer)
    }
    
    func addGradient(_ gradientLayer: GradientLayer, cornerRadius: CGFloat = 0) {
        if let sublayers = base.layer.sublayers {
            for subLayer in sublayers {
                if subLayer.name == "dengTaGradient" {
                    subLayer.removeFromSuperlayer()
                    break
                }
            }
        }
        
        let cloneGradient = gradientLayer.clone()
        cloneGradient.name = "dengTaGradient"
        cloneGradient.frame = base.bounds
        cloneGradient.cornerRadius = cornerRadius
        base.layer.insertSublayer(cloneGradient, at: 0)
    }
}

public extension DengTa where Base: UIColor {
    
    static func fromGradient(_ gradient: GradientLayer, frame: CGRect, cornerRadius: CGFloat = 0) -> UIColor? {
        guard let image = UIImage.dt.fromGradient(gradient, frame: frame, cornerRadius: cornerRadius) else { return nil }
        return UIColor(patternImage: image)
    }
    
    static func fromGradientWithDirection(_ direction: GradientDirection, frame: CGRect, colors: [UIColor], cornerRadius: CGFloat = 0, locations: [Double]? = nil) -> UIColor? {
        let gradient = GradientLayer(direction: direction, colors: colors, cornerRadius: cornerRadius, locations: locations)
        return UIColor.dt.fromGradient(gradient, frame: frame)
    }
}

public extension DengTa where Base: UIImage {
    
    static func fromGradient(_ gradient: GradientLayer, frame: CGRect, cornerRadius: CGFloat = 0) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        let cloneGradient = gradient.clone()
        cloneGradient.frame = frame
        cloneGradient.cornerRadius = cornerRadius
        cloneGradient.render(in: ctx)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return image
    }
    
    static func fromGradientWithDirection(_ direction: GradientDirection, frame: CGRect, colors: [UIColor], cornerRadius: CGFloat = 0, locations: [Double]? = nil) -> UIImage? {
        let gradient = GradientLayer(direction: direction, colors: colors, cornerRadius: cornerRadius, locations: locations)
        return UIImage.dt.fromGradient(gradient, frame: frame)
    }
}

