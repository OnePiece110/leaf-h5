//
//  DTCutDownView.swift
//  DT
//
//  Created by Ye Keyon on 2021/2/11.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit
import RxSwift

protocol DTCutDownViewDelegate:class {
    func startCutDown()
}

class DTCutDownView: UIView {

    weak var delegate:DTCutDownViewDelegate?
    let disposeBag = DisposeBag()
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubView()
        self.dt.viewTarget(add: self, action: #selector(startCutDown))
    }
    
    @objc private func startCutDown() {
        self.delegate?.startCutDown()
        self.isUserInteractionEnabled = false
    }
    
    public func startCutDownAction() {
        DTLoginSchedule.timer(duration: 60).subscribe(onNext: { [weak self] (second) in
            guard let weakSelf = self else { return }
            weakSelf.setTitle("重新发送（\(second)）")
        }, onError: { [weak self] (error) in
            guard let weakSelf = self else { return }
            weakSelf.setTitle("获取验证码")
            weakSelf.isUserInteractionEnabled = true
        }, onCompleted: { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.setTitle("获取验证码")
            weakSelf.isUserInteractionEnabled = true
        }).disposed(by: disposeBag)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.dt.addGradient(GradientLayer(direction: .leftToRight, colors: [APPColor.color36BDB8, APPColor.color00B170]))
    }
    
    private func configSubView() {
        addSubview(codeLabel)
        codeLabel.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(self)
        }
    }
    
    public func setTitle(_ title: String) {
        codeLabel.text = title
    }
    
    private lazy var codeLabel: UILabel = {
        let codeLabel = UILabel().dt
            .text("获取验证码")
            .font(UIFont.dt.Font(14))
            .textColor(APPColor.colorWhite)
            .build
        return codeLabel
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
