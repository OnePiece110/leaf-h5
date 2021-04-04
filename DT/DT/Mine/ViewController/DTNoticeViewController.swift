//
//  DTNoticeViewController.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/11.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import SnapKit
import ObjectiveC
import MJRefresh
import RxSwift

class DTNoticeViewController: DTBaseViewController,Routable {

    static func initWithParams(params: [String: Any]?) -> UIViewController {
        let vc = DTNoticeViewController()
        return vc
    }
    
    private let viewModel = DTNoticeViewModel()
    private var tableView: UITableView?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "消息中心"
        createTableView()
        self.tableView?.mj_header?.beginRefreshing()
    }
    
    func createTableView() {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.register(DTNoticeCell.self, forCellReuseIdentifier: "DTNoticeCell")
        let header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.viewModel.refresh().subscribe { (json) in
                tableView.reloadData()
                tableView.mj_header?.endRefreshing()
            } onError: { (error) in
                tableView.mj_header?.endRefreshing()
            }.disposed(by: weakSelf.disposeBag)
        })
        header.stateLabel?.textColor = .white
        header.lastUpdatedTimeLabel?.textColor = .white
        tableView.mj_header = header
        
        let footer = MJRefreshBackNormalFooter(refreshingBlock: { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.viewModel.loadMore().subscribe { (json) in
                tableView.reloadData()
                tableView.mj_footer?.endRefreshing()
            } onError: { (error) in
                tableView.mj_footer?.endRefreshing()
            }.disposed(by: weakSelf.disposeBag)
        })
        footer.stateLabel?.textColor = .white
        tableView.mj_footer = footer
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

extension DTNoticeViewController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DTNoticeCell", for: indexPath) as! DTNoticeCell
        cell.readData(model: self.viewModel.dataSource[indexPath.row])
        return cell
    }
}

extension DTNoticeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: kScreentWidth, height: 50))
            label.textAlignment = .center
            label.text = "更早的消息"
            label.textColor = UIColor.white.withAlphaComponent(0.5)
            label.font = UIFont.dt.Font(14)
            label.lineBreakMode = .byCharWrapping
            return label
        } else {
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 40
        } else {
            return 10
        }
    }
}
