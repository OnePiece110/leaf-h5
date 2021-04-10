//
//  DTVPNListViewController.swift
//  DT
//
//  Created by Ye Keyon on 2021/1/16.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class DTVPNListViewController: DTBaseViewController, Routable {

    static func initWithParams(params: [String : Any]?) -> UIViewController {
        let vc = DTVPNListViewController()
        if let params = params {
            if let delegate = params["delegate"] as? DTRouteSelectViewControllerDelegate {
                vc.delegate = delegate
            }
        }
        return vc
    }
    
    private var viewModel = DTRouteSelectViewModel()
    private let disposeBag = DisposeBag()
    weak var delegate:DTRouteSelectViewControllerDelegate?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.separatorColor = .clear
        tableView.estimatedRowHeight = 0
        tableView.backgroundColor = .clear
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.register(DTRouteSectionCell.self, forCellReuseIdentifier: "DTRouteSectionCell")
        tableView.register(DTRouteRowCell.self, forCellReuseIdentifier: "DTRouteRowCell")
        tableView.register(DTSmartLinkCell.self, forCellReuseIdentifier: "DTSmartLinkCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "选择线路"
        self.configRightItems()
        self.configSubView()
        self.configureData()
    }
    
    private func configRightItems() {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(rightItemClick(button:)), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 72, height: 44)
        button.setImage(UIImage(named: "icon_route_show"), for: .normal)
        button.setImage(UIImage(named: "icon_route_close"), for: .selected)
        let rightItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItems = [rightItem]
    }
    
    private func configSubView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(0)
            }
        }
    }
    
    private func configureData() {
        DTProgress.showProgress(in: self)
        self.viewModel.list().subscribe(onNext: { [weak self] (json) in
            guard let weakSelf = self else { return }
            DTProgress.dismiss(in: weakSelf)
            self?.tableView.reloadData()
        }, onError: { [weak self ] (error) in
            guard let weakSelf = self else { return }
            DTProgress.showError(in: weakSelf, message: "请求失败")
        }).disposed(by: disposeBag)
    }
    
    //MARK: -- action
    @objc private func rightItemClick(button: UIButton) {
        button.isSelected = !button.isSelected
        closeOrShowItems(isShow: button.isSelected)
    }
    
    private func closeOrShowItems(isShow: Bool) {
        for item in self.viewModel.normalSectionList {
            item.isOpen = isShow
        }
        self.tableView.reloadData()
    }

}

extension DTVPNListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.normalSectionList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.viewModel.normalSectionList[section].isOpen {
            return self.viewModel.normalSectionList[section].serverVOList.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionModel = self.viewModel.normalSectionList[indexPath.section]
        if sectionModel.groupId == -1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DTSmartLinkCell", for: indexPath) as! DTSmartLinkCell
            cell.model = sectionModel
            return cell
        } else if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DTRouteSectionCell", for: indexPath) as! DTRouteSectionCell
            cell.model = sectionModel
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DTRouteRowCell", for: indexPath) as! DTRouteRowCell
            let model = sectionModel.serverVOList[indexPath.row-1]
            cell.readData(model: model, currentIndex: indexPath.row-1, count: sectionModel.serverVOList.count)
            return cell
        }
    }
}

extension DTVPNListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionModel = self.viewModel.normalSectionList[indexPath.section]
        if sectionModel.groupId == -1 {
            return 70
        }
        return 49
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionModel = self.viewModel.normalSectionList[indexPath.section]
        if sectionModel.groupId == -1 {
            self.popSelf()
            let serverData = DTServerVOItemData()
            serverData.name = "智能连接"
            serverData.itemId = -1
            self.delegate?.routeClick(model: serverData)
        } else if indexPath.row == 0 {
            sectionModel.isOpen = !sectionModel.isOpen
            self.tableView.reloadData()
        } else {
            let model = sectionModel.serverVOList[indexPath.row-1]
            self.popSelf()
            self.delegate?.routeClick(model: model)
        }
    }
}


