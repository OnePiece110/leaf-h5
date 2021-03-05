//
//  DTBaseTableViewCell.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/11.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import SnapKit

class DTBaseTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.backgroundColor = .clear
    }
    
}
