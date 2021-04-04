//
//  DTUserProfileViewController.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/12.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

class DTUserProfileViewController: DTBaseViewController,Routable {

    static func initWithParams(params: [String: Any]?) -> UIViewController {
        let vc = DTUserProfileViewController()
        return vc
    }
    
    var viewModel = DTUserProfileViewModel()
    var tableView:UITableView!
    var headerView:DTMineHeaderView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.headerView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "个人中心"
        createTableView()
//        configureTableView()
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
    
    func createTableView() {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.register(DTUserProfileCell.self, forCellReuseIdentifier: "DTUserProfileCell")
        tableView.register(DTLogoutCell.self, forCellReuseIdentifier: "DTLogoutCell")
        tableView.register(DTAvatarCell.self, forCellReuseIdentifier: "DTAvatarCell")
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

extension DTUserProfileViewController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.tableData[section].rowData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = viewModel.tableData[indexPath.section].rowData[indexPath.row]
        switch model.type {
        case .logout:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DTLogoutCell", for: indexPath) as! DTLogoutCell
            cell.model = model
            return cell
        case .avatar:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DTAvatarCell", for: indexPath) as! DTAvatarCell
            cell.model = model
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DTUserProfileCell", for: indexPath) as! DTUserProfileCell
            cell.model = model
            return cell
        }
    }
}

extension DTUserProfileViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.tableData[indexPath.section].rowData[indexPath.row].height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.tableData[section].sectionHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModel.tableData[indexPath.section].rowData[indexPath.row]
        if !model.isEnable {
            return
        }
        switch model.type {
        case .bindInvite:
            debugPrint("bindInvite")
            break
        case .device:
            debugPrint("device")
            break
        case .phone:
            debugPrint("phone")
            break
        case .email:
            debugPrint("email")
            break
        case .password:
            Router.routeToClass(DTForgetPasswordViewController.self, params: ["title":"修改密码"])
            break
        case .logout:
            let logOutView = DTLogOutPopupView.logOutPopup()
            logOutView.alertManager?.show()
            logOutView.delegate = self
        case .avatar:
            Router.routeToClass(DTUpdateAvatarViewController.self)
            break
        case .username:
            Router.routeToClass(DTUpdateUserNameViewController.self)
            break
        }
    }
}

extension DTUserProfileViewController: DTLogOutPopupViewDelegate {
    func sureButtonClick() {
        DTUser.sharedUser.clearData()
        self.popSelf()
    }
    
    func cancelButtonClick() {
        
    }
}
