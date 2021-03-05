/**
 *  @file        DTTextView.swift
 */

import UIKit

@objc protocol DTTextViewDelegate {
    func stretchyTextViewDidChangeSize(textView: DTTextView)
}

enum DTPlaceHolderVerticalAlignment {
    case Top, Center
}

class DTTextView: UITextView, UITextViewDelegate {
    
    // MARK: - PlaceHolder
    
    var placeHolderLabel: UILabel?
    
    var placeHolderColor = UIColor.white.withAlphaComponent(0.2) {
        didSet {
            placeHolderLabel?.textColor = placeHolderColor
        }
    }
    
    var placeholder: String? {
        didSet {
            if let label = placeHolderLabel {
                label.text = placeholder
                label.numberOfLines = 0
                label.lineBreakMode = NSLineBreakMode.byWordWrapping
                autoSizeWithPlaceHolder()
            } else {
                setupPlaceHolderLabel()
            }
        }
    }
    
    override var textContainerInset: UIEdgeInsets {
        didSet {
            autoSizeWithPlaceHolder()
        }
    }
    
    override var font: UIFont! {
        didSet {
            if let label = placeHolderLabel  {
                label.font = font
                autoSizeWithPlaceHolder()
            }
        }
    }
    
    override var text: String! {
        didSet {
            textChanged()
        }
    }
    
    func autoSizeWithPlaceHolder() {
        if let label = placeHolderLabel {
            label.snp.updateConstraints { (make) in
                make.left.equalTo(textContainerInset.left+4.5)
                make.top.equalTo(textContainerInset.top)
                make.right.equalTo(-textContainerInset.left-4.5)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        comminit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        comminit()
    }
    
    private func comminit() {
        if placeholder != nil {
            setupPlaceHolderLabel()
        }
    }
    
    private func setupPlaceHolderLabel() {
		if self.placeHolderLabel != nil {
			return
		}
        let left = textContainerInset.left
        let frame = CGRect(x: left, y: textContainerInset.top, width: bounds.width - left * 2, height: bounds.height - textContainerInset.top * 2)
        let placeHolderLabel = UILabel(frame: frame)
        placeHolderLabel.font = font
        placeHolderLabel.textColor = placeHolderColor
        placeHolderLabel.adjustsFontSizeToFitWidth = false
        placeHolderLabel.text = placeholder
        placeHolderLabel.tag = 123456
		placeHolderLabel.numberOfLines = 0
		placeHolderLabel.lineBreakMode = .byWordWrapping
        addSubview(placeHolderLabel)
        self.placeHolderLabel = placeHolderLabel
        placeHolderLabel.snp.makeConstraints { (make) in
            make.left.equalTo(textContainerInset.left+4.5)
            make.top.equalTo(textContainerInset.top)
            make.right.equalTo(-textContainerInset.left-4.5)
        }
        
        autoSizeWithPlaceHolder()
		NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    @objc func textChanged() {
        if let placeholder = placeholder, placeholder.count == 0 {
            return
        }
        
        if self.text.count == 0 {
            self.viewWithTag(123456)?.alpha = 1
        } else {
            self.viewWithTag(123456)?.alpha = 0
        }
    }
}
