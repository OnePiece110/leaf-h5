//
//  DTConstants.swift
//  DT
//
//  Created by Ye Keyon on 2020/6/30.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

class DTConstants {
    ///获取当前页面
    public class func currentTopViewController() -> UIViewController? {
        let window = UIApplication.dt.currentWindow()
        if let rootViewController = window?.rootViewController {
            return currentTopViewController(rootViewController: rootViewController)
        } else {
            return nil
        }
    }
    
    public class func currentTopViewController(rootViewController: UIViewController) -> UIViewController {
        if (rootViewController.isKind(of: UITabBarController.self)) {
            let tabBarController = rootViewController as! UITabBarController
            return currentTopViewController(rootViewController: tabBarController.selectedViewController!)
        }
        if (rootViewController.isKind(of: UINavigationController.self)) {
            let navigationController = rootViewController as! UINavigationController
            return currentTopViewController(rootViewController: navigationController.visibleViewController!)
        }
        if ((rootViewController.presentedViewController) != nil) {
            return currentTopViewController(rootViewController: rootViewController.presentedViewController!)
        }
        return rootViewController
    }
    
    public class func storyBoradVC(storyBoardName: String, identifier: String) -> UIViewController {
        let story = UIStoryboard(name: storyBoardName, bundle: nil)
        return story.instantiateViewController(withIdentifier: identifier)
    }
    
    public class func shadowColor(_ view:UIView, shadowColor:UIColor, shadowOpacity: CGFloat, cornerRadius:CGFloat) {
        view.layer.shadowColor = shadowColor.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0);
        view.layer.shadowOpacity = 1;
        view.layer.cornerRadius = cornerRadius
    }
    
    public class func decimalNumberOfDouble(number num:Double, withScale scale:Int16 = 2) -> String {
        let numString = "\(num)"
        let decNumber = NSDecimalNumber(string: numString)
        let roundingBehavior = NSDecimalNumberHandler(roundingMode: .down, scale: scale, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let roundedOunces = decNumber.rounding(accordingToBehavior: roundingBehavior)
        return roundedOunces.stringValue
    }
    
    public class func jumpToTabBarController(_ selectedIndex:Int) -> UIViewController? {
        let window = UIApplication.dt.currentWindow()
        if let rootViewController = window?.rootViewController {
            if (rootViewController.isKind(of: UITabBarController.self)) {
                let tabBarController = rootViewController as! UITabBarController
                tabBarController.selectedIndex = selectedIndex
                return self.currentTopViewController(rootViewController: tabBarController)
            }
        }
        return nil
    }
    
    public class func checkValidText(textField:UITextField) -> (Bool, String) {
        if let text = textField.text, !text.isVaildEmpty() {
            return (true, text)
        }
        return (false, "")
    }
    
    public class func checkValidText(textView:UITextView) -> (Bool, String) {
        if !textView.text.isVaildEmpty() {
            return (true, textView.text)
        }
        return (false, "")
    }
}
