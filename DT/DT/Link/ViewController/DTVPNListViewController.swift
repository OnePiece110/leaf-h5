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

protocol DTVPNListViewControllerDelegate:class {
    func routeClick(model: DTServerVOItemData)
}

class DTVPNListViewController: DTBaseViewController, Routable {

    static func initWithParams(params: [String : Any]?) -> UIViewController {
        let vc = DTVPNListViewController()
        if let params = params {
            if let delegate = params["delegate"] as? DTVPNListViewControllerDelegate {
                vc.delegate = delegate
            }
        }
        return vc
    }
    
    private var viewModel = DTRouteSelectViewModel()
    private let disposeBag = DisposeBag()
    weak var delegate: DTVPNListViewControllerDelegate?
    
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
//        self.configureData()
        DTLineTool.shared.requestData(vc: self) { [weak self] in
            self?.tableView.reloadData()
        } reloadBlock: { [weak self] in
            self?.tableView.reloadData()
        }

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
    
//    private func configureData() {
//        DTProgress.showProgress(in: self)
//        DTLineTool.shared.list().subscribe(onNext: { [weak self] (json) in
//            guard let weakSelf = self else { return }
//            DTProgress.dismiss(in: weakSelf)
//            weakSelf.pingAllDomain()
//            self?.tableView.reloadData()
//        }, onError: { [weak self ] (error) in
//            guard let weakSelf = self else { return }
//            DTProgress.showError(in: weakSelf, message: "请求失败")
//        }).disposed(by: disposeBag)
//    }
    
    //MARK: -- action
    @objc private func rightItemClick(button: UIButton) {
        button.isSelected = !button.isSelected
        closeOrShowItems(isShow: button.isSelected)
    }
    
    private func closeOrShowItems(isShow: Bool) {
        for item in DTLineTool.shared.normalSectionList {
            item.isOpen = isShow
        }
        self.tableView.reloadData()
    }

}

extension DTVPNListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return DTLineTool.shared.normalSectionList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if DTLineTool.shared.normalSectionList[section].isOpen {
            return DTLineTool.shared.normalSectionList[section].serverVOList.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionModel = DTLineTool.shared.normalSectionList[indexPath.section]
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
        let sectionModel = DTLineTool.shared.normalSectionList[indexPath.section]
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
        let sectionModel = DTLineTool.shared.normalSectionList[indexPath.section]
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
    
    private func pingAllDomain() {
        var pingObsebables = [Observable<Double>]()
        var pingResultCount = 0
        for group in DTLineTool.shared.normalSectionList {
            for item in group.serverVOList {
                let observer = self.pingRow(model: item).do { [weak self] (ping) in
                    guard let weakSelf = self else { return }
                    item.ping = ping
                    pingResultCount += 1
                    if pingResultCount % 4 == 0 {
                        weakSelf.tableView.reloadData()
                    }
                } onError: { (err) in
                    debugPrint(err)
                }
                pingObsebables.append(observer)
            }
        }
        Observable.concat(pingObsebables).subscribe(on: SerialDispatchQueueScheduler(internalSerialQueueName: "dt.group.ping")).map{ $0 }.toArray().subscribe { [weak self] (pingDatas) in
            guard let weakSelf = self else { return }
            weakSelf.tableView.reloadData()
        } onFailure: { (err) in
            print(err)
        }.disposed(by: disposeBag)

    }
    
    private func pingRow(model: DTServerVOItemData) -> Observable<Double> {
        return Observable<Double>.create { (observer) -> Disposable in
            let ping = SwiftyPing(configuration: PingConfiguration(interval: 1.0, with: 1), queue: DispatchQueue.global())
            ping.targetCount = 1
            ping.observer = { (response) in
                observer.onNext(response.duration! * 1000)
                observer.onCompleted()
            }
            ping.startPing(host: model.domain)
            return Disposables.create {
                
            }
        }
    }
}


