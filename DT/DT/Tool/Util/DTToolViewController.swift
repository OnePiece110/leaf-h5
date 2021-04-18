//
//  WGToolViewController.swift
//  WeiGuGlobal
//
//  Created by YeKeyon on 2019/12/4.
//  Copyright © 2019 com.chuang.global. All rights reserved.
//

import UIKit

class DTToolViewController: DTBaseViewController, Routable  {
    
    static func initWithParams(params: [String : Any]?) -> UIViewController {
        let vc = DTToolViewController()
        return vc
    }
    
    @objc var viewModel = DTToolViewModel()
    private var tableView: UITableView?
    private weak var popupView: DTAlertBaseView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "测试专用"
        self.configureSubViews()
    }
    
    func configureSubViews() {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 0
        tableView.backgroundColor = .clear
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(0)
            }
        }
        self.tableView = tableView
    }
}

extension DTToolViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.backgroundColor = UIColor.black
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = self.viewModel.dataSource[indexPath.row]
        return cell
    }
}

extension DTToolViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let updatePopup = DTAlertBaseView()
            updatePopup.readData(icon: UIImage(named: "icon_logo"), title: "切换环境", message: "")
            updatePopup.addAction("测试环境", titleColor: UIColor.white.withAlphaComponent(0.5), bgColor: APPColor.colorSubBgView, target: self, selector: #selector(changeDebug))
            updatePopup.addAction("正式环境", titleColor: UIColor.white.withAlphaComponent(0.5), bgColor: APPColor.colorSubBgView, target: self, selector: #selector(changeRelease))
            updatePopup.finish()
            updatePopup.alertManager?.show()
            self.popupView = updatePopup
        } else if indexPath.row == 1 {
            Router.routeToClass(DTLogsViewController.self, params: nil)
        }
    }
    
    @objc private func changeDebug() {
        baseUrl = "https://api-dev.mytube.vip/"
        downloadUrl = "https://api-dev.mytube.vip/rules/"
        self.popupView?.alertManager?.dimiss()
    }
    
    @objc private func changeRelease() {
        baseUrl = "https://api.yinli.ga/"
        downloadUrl = "https://api.yinli.ga/rules/"
        self.popupView?.alertManager?.dimiss()
    }
}
