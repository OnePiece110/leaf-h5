//
//  DTMineViewController.swift
//  DT
//
//  Created by Ye Keyon on 2020/6/30.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import RxSwift

class DTMineViewController: DTBaseViewController {

    @IBOutlet weak var tableView: UITableView!
    private let viewModel = DTMineViewModel()
    private var headerView:DTMineHeaderView?
    private weak var popupView: DTAlertBaseView?
    private let disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.reloadData()
        self.headerView?.reloadData()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureTableView()
        configureCell()
    }
    
    func configure() -> Void {
        self.navigationItem.title = "我的"
        self.tabBarItem.title = "我的"
    }
    
    func configureCell() {
        tableView.backgroundColor = .clear
        tableView.register(DTMineCell.self, forCellReuseIdentifier: "DTMineCell")
        tableView.register(DTMineTopUpCell.self, forCellReuseIdentifier: "DTMineTopUpCell")
        tableView.register(DTLogoutCell.self, forCellReuseIdentifier: "DTLogoutCell")
    }
    
    func configureTableView() {
        let headerView = DTMineHeaderView(frame: CGRect(x: 0, y: 0, width: kScreentWidth, height: 104))
        tableView.tableHeaderView = headerView
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        self.headerView = headerView
    }
    
    @objc private func startUpdate() {
        self.popupView?.alertManager?.dimiss()
    }
    
    @objc private func cancelUpdate() {
        self.popupView?.alertManager?.dimiss()
    }

}

extension DTMineViewController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableData[section].rowData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewModel.tableData[indexPath.section].rowData[indexPath.row]
        switch model.type {
        case .advertisement:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DTMineTopUpCell", for: indexPath) as! DTMineTopUpCell
            cell.delegate = self
            cell.model = model
            return cell
        case .logout:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DTLogoutCell", for: indexPath) as! DTLogoutCell
            cell.mineModel = model
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DTMineCell", for: indexPath) as! DTMineCell
            cell.model = model
            return cell
        }
    }
}

extension DTMineViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = viewModel.tableData[indexPath.section].rowData[indexPath.row]
        return model.height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.tableData[section].sectionHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return viewModel.tableData[section].sectionFooter
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModel.tableData[indexPath.section].rowData[indexPath.row]
        switch model.type {
        case .setting:
            Router.routeToClass(DTSettingViewController.self, params: nil)
            break
        case .advertisement:
            debugPrint("advertisement")
            break
        case .question:
            Router.routeToClass(DTWebViewController.self, params: [DTWKURL: baseUrl + "h5/question/question.html"])
            break
        case .tool:
            debugPrint("tool")
            break
        case .star:
            let commentPopup = DTCommentPopupView.commentPopup()
            commentPopup.alertManager?.show()
            break
        case .update:
            DTProgress.showProgress(in: self)
            self.viewModel.versionCheck().subscribe { [weak self] (json) in
                guard let weakSelf = self else { return }
                DTProgress.dismiss(in: weakSelf)
                if !weakSelf.viewModel.updateModel.version.isVaildEmpty() {
                    weakSelf.openPopup()
                } else {
                    weakSelf.unUpdatePopup()
                }
            } onError: { [weak self] (error) in
                guard let weakSelf = self else { return }
                DTProgress.showError(in: weakSelf, message: "请求失败")
            }.disposed(by: disposeBag)
            break
        case .feedback:
            Router.routeToClass(DTFeedbackViewController.self, params: nil)
        case .logout:
            let logOutView = DTLogOutPopupView.logOutPopup()
            logOutView.alertManager?.show()
            logOutView.delegate = self
        }
    }
    
    private func unUpdatePopup() {
        let updatePopup = DTAlertBaseView()
        updatePopup.alertManager?.isDimissTapBgView = false
        updatePopup.readData(icon: UIImage(named: "icon_logo"), title: "已是最新版本", message: "")
        updatePopup.addAction("我知道了", titleColor: UIColor.white.withAlphaComponent(0.5), bgColor: APPColor.colorSubBgView, target: self, selector: #selector(cancelUpdate))
        updatePopup.finish()
        updatePopup.alertManager?.show()
        self.popupView = updatePopup
    }
    
    private func openPopup() {
        let updatePopup = DTAlertBaseView()
        updatePopup.alertManager?.isDimissTapBgView = false
        updatePopup.readData(icon: UIImage(named: "icon_logo"), title: "发现新版本", message: "发现了引力加速器最新的v\(self.viewModel.updateModel.version)版本\n我们强烈建议您进行更新，是否立即更新？")
        updatePopup.addGradientAction("立即更新", titleColor: APPColor.colorWhite, direction: .leftToRight, colors: [APPColor.color36BDB8, APPColor.color00B170], target: self, selector: #selector(startUpdate))
        if self.viewModel.updateModel.forceFlag == 0 {
            updatePopup.addAction("暂不更新", titleColor: UIColor.white.withAlphaComponent(0.5), bgColor: APPColor.colorSubBgView, target: self, selector: #selector(cancelUpdate))
        } else {
            updatePopup.addDesc("不更新则无法继续使用本APP", titleColor: APPColor.color36BDB8)
        }
        
        updatePopup.finish()
        updatePopup.alertManager?.show()
        self.popupView = updatePopup
    }
}

extension DTMineViewController: DTMineTopUpCellDelegate {
    func advertisementCloseClick() {
        var advertisementData: DTMineRowModel?
        var advertisementSectionIndex = -1
        for (index, section) in viewModel.tableData.enumerated() {
            if let _ = advertisementData {
                break
            }
            for row in section.rowData {
                if row.type == .advertisement {
                    advertisementData = row
                    advertisementSectionIndex = index
                    break
                }
            }
        }
        if advertisementSectionIndex > -1 {
            viewModel.tableData.remove(at: advertisementSectionIndex)
            tableView.reloadData()
        }
    }
}

extension DTMineViewController: DTLogOutPopupViewDelegate {
    func sureButtonClick() {
        DTUser.sharedUser.clearData()
        self.viewModel.reloadData()
        self.headerView?.reloadData()
        tableView.reloadData()
    }
    
    func cancelButtonClick() {
        
    }
}
