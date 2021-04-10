//
//  DTSettingViewController.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/11.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

class DTSettingViewController: DTBaseViewController,Routable {

    static func initWithParams(params: [String: Any]?) -> UIViewController {
        let vc = DTSettingViewController()
        return vc
    }
    
    var viewModel = DTSettingViewModel()
    var tableView: UITableView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var mode = DTProxyMode.smart
        if let modeNum = DTUserDefaults?.integer(forKey: DTProxyModeKey) {
            mode = DTProxyMode(rawValue: modeNum) ?? .smart
        }
        var descText = "智能模式(推荐)"
        switch mode {
        case .smart:
            descText = "智能模式(推荐)"
        case .direct:
            descText = "直连模式"
        case .proxy:
            descText = "全局模式"
        }
        viewModel.tableData[0].rowData[0].descText = descText
        self.tableView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "设置"
        createTableView()
    }
    
    func createTableView() {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.register(DTSettingCell.self, forCellReuseIdentifier: "DTSettingCell")
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(0)
            }
        }
        self.tableView = tableView
    }
}

extension DTSettingViewController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.tableData[section].rowData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DTSettingCell", for: indexPath) as! DTSettingCell
        cell.model = self.viewModel.tableData[indexPath.section].rowData[indexPath.row]
        return cell
    }
}

extension DTSettingViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.viewModel.tableData[section].sectionHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.viewModel.tableData[section].sectionFooter
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.viewModel.tableData[indexPath.section].rowData[indexPath.row]
        switch model.type {
        case .proxyMode:
            Router.routeToClass(DTProxyModeViewController.self, params: nil)
            break
        case .lineSetting:
            Router.routeToClass(DTDefaultRouteViewController.self, params: nil)
            break
        case .privacyPolicy:
            debugPrint("privacyPolicy")
            Router.routeToClass(DTWebViewController.self, params: [DTWKURL: baseUrl + "h5/PrivacyPolicy/PrivacyPolicy.html"])
            break
        case .serverTerms:
            debugPrint("serverTerms")
            Router.routeToClass(DTWebViewController.self, params: [DTWKURL: baseUrl + "h5/TermsService/TermsService.html"])
            break
        }
    }
}
