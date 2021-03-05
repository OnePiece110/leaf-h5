//
//  DTBackView.swift
//  Miaosu
//
//  Created by 叶金永 on 2019/1/19.
//  Copyright © 2019 Keyon. All rights reserved.
//

import UIKit

class DTBackView: UIView {

	var backBtn:UIButton!
	init(frame: CGRect, imageName:String) {
		super.init(frame: frame)
		self.backBtn = UIButton(frame: frame)
		self.backBtn.setImage(UIImage(named: imageName), for: .normal)
		self.backBtn.setImage(UIImage(named: imageName), for: .highlighted)
		self.backBtn.contentHorizontalAlignment = .left
		self.addSubview(self.backBtn)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let plusButtonFrame = self.backBtn.frame
		if plusButtonFrame.contains(point) {
			return self.backBtn
		}
		let view = super.hitTest(point, with: event)
		return view
	}
	
}
