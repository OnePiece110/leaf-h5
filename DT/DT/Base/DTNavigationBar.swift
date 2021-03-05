//
//  DTNavigationBar.swift
//  Miaosu
//
//  Created by 叶金永 on 2019/1/19.
//  Copyright © 2019 Keyon. All rights reserved.
//

import UIKit

class DTNavigationBar: UINavigationBar {
	override func sizeToFit() {
		super.sizeToFit()
	}
	
	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		var result:UIView?
		for view in self.subviews {
            let classStr1 = view.dt.theClassName
			if classStr1 == "_UINavigationBarContentView" {
				let subView = view
				for view in subView.subviews {
                    let classStr1 = view.dt.theClassName
					if classStr1 == "_UIButtonBarStackView" {
						let subView = view
						for view in subView.subviews {
                            let classStr1 = view.dt.theClassName
							if classStr1 == "_UITAMICAdaptorView" {
								let subView = view
								for view in subView.subviews {
                                    let classStr1 = view.dt.theClassName
									if classStr1 == String(describing: DTBackView.self) {
										result = view
									}
								}
							}
						}
					}
				}
			}
		}
		if let result = result {
			let plusButtonFrame = result.frame;
			if plusButtonFrame.contains(point) {
				return result
			} else {
				return super.hitTest(point, with: event)
			}
		} else {
			return super.hitTest(point, with: event)
		}
	}
}
