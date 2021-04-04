//
//  Extension.swift
//  Miaosu
//
//  Created by 叶金永 on 2019/1/8.
//  Copyright © 2019 Keyon. All rights reserved.
//

import UIKit
import Foundation
import CommonCrypto

//MARK -- Encodable
extension Encodable {
	func encode(with encoder: JSONEncoder = JSONEncoder()) throws -> Data {
		return try encoder.encode(self)
	}
}

//MARK -- Decodable
extension Decodable {
	static func decode(with decoder: JSONDecoder = JSONDecoder(), from data: Data) throws -> Self {
		return try decoder.decode(Self.self, from: data)
	}
}

//MARK -- UIImage
public extension DengTa where Base: UIImage {
    static func imageWithColor(color: UIColor) -> UIImage{
        let rect = CGRect(x: 0, y: 0, width: 0.5, height: 0.5)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let img:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }
}

//MARK -- UIViewController
public extension DengTa where Base: UIViewController {
    func dismissMe(animated: Bool, completion: (()->())? = nil) {
        var count = 0
        if let c = self.base.navigationController?.viewControllers.count {
            count = c
        }
        if count > 1 {
            self.base.navigationController?.popViewController(animated: animated)
            if let handler = completion {
                handler()
            }
        } else {
            base.dismiss(animated: animated, completion: completion)
        }
    }
}

//MARK: -- UIVIew
public extension DengTa where Base: UIView {
    func configRectCorner(view: UIView, corner: UIRectCorner, radii: CGSize) {
        
        let maskPath = UIBezierPath.init(roundedRect: view.bounds, byRoundingCorners: corner, cornerRadii: radii)
        
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame = view.bounds
        maskLayer.path = maskPath.cgPath
        base.layer.mask = maskLayer;
    }
    
    
}

//MARK: -- String
extension String {
    func substingInRange(_ r: Range<Int>) -> String? {
        if r.lowerBound < 0 || r.upperBound > self.count {
            return nil
        }
        let startIndex = self.index(self.startIndex, offsetBy:r.lowerBound)
        let endIndex   = self.index(self.startIndex, offsetBy:r.upperBound)
        return String(self[startIndex..<endIndex])
    }
    
    /// 从String中截取出参数
    var urlParameters: [String: Any]? {
        // 截取是否有参数
        guard let urlComponents = NSURLComponents(string: self), let queryItems = urlComponents.queryItems else {
            return nil
        }
        // 参数字典
        var parameters = [String: Any]()
        // 遍历参数
        queryItems.forEach({ (item) in
            // 判断参数是否是数组
            if let existValue = parameters[item.name], let value = item.value {
                // 已存在的值，生成数组
                if var existValue = existValue as? [Any] {
                    existValue.append(value)
                } else {
                    parameters[item.name] = [existValue, value]
                }
            } else {
                parameters[item.name] = item.value
            }
        })
        return parameters
    }
    
    func isVaildEmpty() -> Bool {
        let newStr = self.trimmingCharacters(in: .whitespaces)
        if newStr.isEmpty {
            return true
        } else {
            return false
        }
    }
}
//MARK -- UIColor
public extension DengTa where Base: UIColor {
    static func hex(_ hex: String, alpha: CGFloat = 1.0) -> UIColor {
        var hexColor = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexColor.hasPrefix("0X") || hexColor.hasPrefix("0x") {
            hexColor = hexColor.substingInRange(Range(2...hexColor.count-1))!
        }
        if hexColor.hasPrefix("#") {
            hexColor = hexColor.substingInRange(Range(1...hexColor.count-1))!
        }
        
        if (hexColor.count != 6){
            return UIColor.black
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: hexColor).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

//MARK -- NSDictionary
public extension DengTa where Base: NSDictionary {
    func dicTransferString() -> String {
        let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        let str = String.init(data: data!, encoding: String.Encoding.utf8)
        return str!
    }
}

//MARK -- NSObject
public extension DengTa where Base: NSObject {
    var theClassName: String {
        let name =  type(of: self.base).description()
        if (name.contains(".")) {
            return name.components(separatedBy: ".")[1];
        } else {
            return name;
        }
    }
}

//MARK -- Date
extension Date {
    
    /// 获取当前 秒级 时间戳 - 10位
    var timeStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }
    
    /// 获取当前 毫秒级 时间戳 - 13位
    var milliStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
    
    /// 判断是否过了半天
    func isAfterHalfDay() -> Bool {
        let lastDateValue = DTUserDefaults?.object(forKey: DTConstantsKey.HalfDayKey)
        let nowDate = Date()
        guard let lastDate = lastDateValue as? Date else {
            DTUserDefaults?.set(nowDate, forKey: DTConstantsKey.HalfDayKey)
            DTUserDefaults?.synchronize()
            return false
        }
        let betweenHours = lastDate.hourBetweenDate(toDate: nowDate)
        debugPrint("betweenHours", betweenHours)
        if betweenHours > 6 {
            DTUserDefaults?.set(nowDate, forKey: DTConstantsKey.HalfDayKey)
            DTUserDefaults?.synchronize()
        }
        
        return betweenHours > 6
    }
    
    func hourBetweenDate(toDate: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour], from: self, to: toDate)
        return components.hour ?? 0
    }
}

//MARK -- UIView
public extension DengTa where Base: UIView {
    //  边线颜色
    var borderColor: UIColor {
        get {
            return UIColor(cgColor: base.layer.borderColor!)
        } set {
            base.layer.borderColor = newValue.cgColor
        }
    }
    
    // 边线宽度
    var borderWidth: CGFloat {
        get {
            return base.layer.borderWidth
        } set {
            base.layer.borderWidth = newValue
        }
    }
    
    // 圆角
     var cornerRadius: CGFloat {
        get {
            return base.layer.cornerRadius
        } set {
            base.layer.cornerRadius = newValue
        }
    }
    
    /// 部分圆角
    /// - Parameters:
    ///   - corners: 需要实现为圆角的角，可传入多个
    ///   - radii: 圆角半径
    func corner(byRoundingCorners corners:UIRectCorner, cornerRadii: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: base.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: cornerRadii, height: cornerRadii))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = base.bounds
        maskLayer.path = maskPath.cgPath
        base.layer.mask = maskLayer
    }
    /// 全部圆角
    /// - Parameters:
    ///   - radii: 圆角半径
    func cornerAllRound(cornerRadii: CGFloat) {
        self.corner(byRoundingCorners: UIRectCorner.allCorners, cornerRadii: cornerRadii)
    }
    
    @discardableResult
    func viewTarget(add target: Any?, action: Selector) -> DengTa {
        let tap = UITapGestureRecognizer(target: target, action: action)
        base.addGestureRecognizer(tap)
        base.isUserInteractionEnabled = true
        return self
    }
    
}

extension UILabel {
    /// UILabel根据文字的需要的高度
    public var requiredHeight: CGFloat {
        let label = UILabel(frame: CGRect(
            x: 0,
            y: 0,
            width: frame.width,
            height: CGFloat.greatestFiniteMagnitude)
        )
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = text
        label.attributedText = attributedText
        label.sizeToFit()
        return label.frame.height
    }
    
    public func gradient(_ direction: GradientDirection, frame: CGRect, colors: [UIColor], cornerRadius: CGFloat = 0, locations: [Double]? = nil) {
        /*
         CAGradientLayer *layer = [[CAGradientLayer alloc] init];
             layer.colors = @[(id)[UIColor redColor].CGColor, (id)[UIColor blueColor].CGColor];
             layer.startPoint = CGPointZero;
             layer.endPoint = CGPointMake(1, 1);
             layer.frame = label.bounds;
             layer.mask = label.layer; //把文字作为渐变图层的遮罩
             [self.view.layer addSublayer:layer];
         */
        let gradientLayer = GradientLayer(direction: direction, colors: colors, cornerRadius: cornerRadius, locations: locations)
        self.layer.mask = gradientLayer
    }
}


public extension DengTa where Base: UIFont {
    static func Font(_ value:CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: value)
    }

    static func Bold_Font(_ value:CGFloat) -> UIFont {
        return UIFont.boldSystemFont(ofSize: value)
    }
}

public extension DengTa where Base: UIApplication {
    static func currentWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first
    }
}


public extension DengTa where Base: UIButton {
    @discardableResult
    ///addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event)
    func target(add target: Any?, action: Selector, event: UIControl.Event = .touchUpInside) -> DengTa {
        base.addTarget(target, action: action, for: event)
        return self
    }
    
//    func target(remove target: Any?, action: Selector, event: UIControl.Event = .touchUpInside) -> DengTa {
//        base.removeTarget(target, action: action, for: event)
//        return self
//    }
    
    @discardableResult
    func select(_ b: Bool) -> DengTa {
        base.isSelected = b
        return self
    }
    
    @discardableResult
    func line(breakMode mode: NSLineBreakMode) -> DengTa {
        base.titleLabel?.lineBreakMode = mode
        return self
    }
    
    @discardableResult
    func font(_ font: UIFont) -> DengTa {
        base.titleLabel?.font = font
        return self
    }
    
    @discardableResult
    func image(_ image: UIImage?, for state:UIControl.State = .normal) -> DengTa {
        base.setImage(image, for: state)
        return self
    }
    @discardableResult
    func background(_ image: UIImage?, for state:UIControl.State = .normal) -> DengTa {
        base.setBackgroundImage(image, for: state)
        return self
    }
    
    @discardableResult
    func attributed(_ title: NSAttributedString, for state:UIControl.State = .normal) -> DengTa {
        base.setAttributedTitle(title, for: state)
        return self
    }
    
    @discardableResult
    func title(_ edgeInsets: UIEdgeInsets) -> DengTa {
        base.titleEdgeInsets = edgeInsets
        return self
    }
    
    @discardableResult
    func title(_ title: String, for state:UIControl.State = .normal) -> DengTa {
        base.setTitle(title, for: state)
        return self
    }
    
    @discardableResult
    func titleColor(_ color: UIColor, for state:UIControl.State = .normal) -> DengTa {
        base.setTitleColor(color, for: state)
        return self
    }
    
    @discardableResult
    func image(_ edgeInsets: UIEdgeInsets) -> DengTa {
        base.imageEdgeInsets = edgeInsets
        return self
    }
    
    @discardableResult
    func image(edgeInsets top: CGFloat = 0, left:CGFloat = 0, bottom:CGFloat = 0, right:CGFloat = 0) -> DengTa {
        base.imageEdgeInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        return self
    }
}

public extension DengTa where Base : UITextField {
    func isValid() -> Bool {
        if let text = base.text, !text.isVaildEmpty() {
            return true
        }
        return false
    }
}
