//
//  DTProxyModeViewController.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/12.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import RxSwift

class DTProxyModeViewController: DTBaseViewController,Routable {

    static func initWithParams(params: [String: Any]?) -> UIViewController {
        let vc = DTProxyModeViewController()
        return vc
    }
    
    private var viewModel = DTDefaultRouteViewModel(type: .proxyMode)
    private var tableView:UITableView?
    private let pb1 = PublishSubject<Int>()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "代理模式"
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
        tableView.register(DTDefaultRouteCell.self, forCellReuseIdentifier: "DTDefaultRouteCell")
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

extension DTProxyModeViewController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DTDefaultRouteCell", for: indexPath) as! DTDefaultRouteCell
        cell.model = self.viewModel.tableData[indexPath.row]
        return cell
    }
}

extension DTProxyModeViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.changeValue(indexPath: indexPath)
        self.tableView?.reloadData()
        pb1.debounce(.milliseconds(500), scheduler: MainScheduler.instance).subscribe { (data) in
            NotificationCenter.default.post(name: NSNotification.Name(PROXY_MODE_CHANGE_Notification), object: nil)
        }.disposed(by: disposeBag)
        pb1.onNext(1)
    }
}
