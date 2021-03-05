//
//  DTVPNPtotocolViewController.swift
//  DT
//
//  Created by Ye Keyon on 2021/2/27.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit

protocol DTVPNPtotocolViewControllerDelegate: class {
    func vpnProtocolItemClick(proto: String)
}

class DTVPNPtotocolViewController: DTBaseViewController, Routable {

    static func initWithParams(params: [String : Any]?) -> UIViewController {
        let vc = DTVPNPtotocolViewController()
        if let delegate = params?["delegate"] as? DTVPNPtotocolViewControllerDelegate {
            vc.delegate = delegate
        }
        return vc
    }
    
    private var dataSource = ["vless", "trojan"]
    private var tableView:UITableView!
    weak var delegate: DTVPNPtotocolViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "协议列表"
        configureSubViews()
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

extension DTVPNPtotocolViewController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.backgroundColor = UIColor.black
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .white
        cell.textLabel?.text = self.dataSource[indexPath.row]
        return cell
    }
}

extension DTVPNPtotocolViewController:UITableViewDelegate {
    
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
        delegate?.vpnProtocolItemClick(proto: self.dataSource[indexPath.row])
        popSelf()
    }
}
