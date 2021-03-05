//
//  DTSelectView.swift
//  DT
//
//  Created by Ye Keyon on 2021/2/12.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit

protocol DTSelectViewDelegate: class {
    func itemClick(selectView: DTSelectView, item: String, index: IndexPath)
}

class DTSelectView: DTCustomRadiusView {

    weak var delegate:DTSelectViewDelegate?
    private let itemHeight:CGFloat = 50
    private var _dataSource = [String]()
    private var tableHeight:CGFloat = 0
    private var tableView:UITableView?
    var dataSource: [String] {
        get {
            return _dataSource
        }
        set {
            _dataSource = newValue
            tableHeight = itemHeight * CGFloat(newValue.count)
            tableView?.snp.updateConstraints({ (make) in
                make.height.equalTo(tableHeight)
            })
            self.tableView?.reloadData()
        }
    }
    
    var alertManager:DTAlertManager?
    class func selectView(dataSource: [String]) -> DTSelectView {
        let selectView = DTSelectView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 50 * CGFloat(dataSource.count) + 60))
        selectView.dataSource = dataSource
        selectView.topLeftRadius = 10
        selectView.topRightRadius = 10
        selectView.alertManager = DTAlertManager(selectView, type: .bottomToTop, cornerRadius: 0)
        return selectView
    }
    
    @objc private func cancelButtonClick() {
        alertManager?.dimiss()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createTableView()
        configSubViews()
    }
    
    private func configSubViews() {
        guard let tableView = tableView else {
            return
        }
        addSubview(tableView)
        tableView.snp.makeConstraints({ (make) in
            make.height.equalTo(tableHeight)
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0))
        })
        
        let cancelButton = UIButton(type: .custom).dt
            .title("取消")
            .font(UIFont.dt.Font(14))
            .titleColor(APPColor.colorWhite)
            .backgroundColor(APPColor.colorWhite.withAlphaComponent(0.1))
            .target(add: self, action: #selector(cancelButtonClick))
            .build
        addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(0)
            make.height.equalTo(50)
        }
    }
    
    private func createTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView?.backgroundColor = .clear
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.isScrollEnabled = false
        tableView?.estimatedSectionHeaderHeight = 0
        tableView?.estimatedSectionFooterHeight = 0
        tableView?.register(DTSelecViewCell.self, forCellReuseIdentifier: "DTSelecViewCell")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.dt.addGradient(GradientLayer(direction: .topToBottom, colors: [APPColor.color054369, APPColor.color082138]))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension DTSelectView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.itemClick(selectView: self,item: _dataSource[indexPath.row], index: indexPath)
    }
}

extension DTSelectView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DTSelecViewCell", for: indexPath) as! DTSelecViewCell
        cell.readData(_dataSource[indexPath.row])
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}
