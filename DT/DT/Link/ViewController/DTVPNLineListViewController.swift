//
//  DTVPNLineListViewController.swift
//  DT
//
//  Created by Ye Keyon on 2021/2/26.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit
import RealmSwift

protocol DTVPNLineListViewControllerDelegate: class {
    func vpnListItemClick(model: DTVPNLineModel)
}

class DTVPNLineModel: Object {
    @objc dynamic var domain = ""
    @objc dynamic var port = 0
    @objc dynamic var passwd = ""
    @objc dynamic var path = ""
    @objc dynamic var host = ""
    @objc dynamic var proto = ""
    @objc dynamic var id = 0
}

class DTVPNLineListViewController: DTBaseViewController,Routable {

    static func initWithParams(params: [String : Any]?) -> UIViewController {
        let vc = DTVPNLineListViewController()
        if let delegate = params?["delegate"] as? DTVPNLineListViewControllerDelegate {
            vc.delegate = delegate
        }
        return vc
    }
    
    private var tableView:UITableView!
    private var dataSource: Results<DTVPNLineModel>?
    private var realm = try! Realm()
    weak var delegate: DTVPNLineListViewControllerDelegate?
    var notificationToken: NotificationToken? = nil
    
    deinit {
        notificationToken?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "配置列表"
        configureSubViews()
        dataSource = realm.objects(DTVPNLineModel.self)
        notificationToken = realm.objects(DTVPNLineModel.self).observe { [weak self] (changes: RealmCollectionChange) in
            guard let weakSelf = self else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                weakSelf.tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                weakSelf.tableView.beginUpdates()
                // Always apply updates in the following order: deletions, insertions, then modifications.
                // Handling insertions before deletions may result in unexpected behavior.
                weakSelf.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                weakSelf.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                weakSelf.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                weakSelf.tableView.endUpdates()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
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
        
        let addButton = UIBarButtonItem(title: "添加", style: .done, target: self, action: #selector(addButtonClick))
        self.navigationItem.rightBarButtonItems = [addButton]
    }
    
    @objc private func addButtonClick() {
        Router.routeToClass(DTVPNLineEditViewController.self)
    }
}

extension DTVPNLineListViewController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        let model = self.dataSource?[indexPath.row]
        cell.backgroundColor = UIColor.black
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = .white
        cell.detailTextLabel?.text = model?.proto ?? ""
        cell.textLabel?.text = "\(model?.proto ?? "") - \(model?.domain ?? ""):\(model?.port ?? 0)"
        return cell
    }
}

extension DTVPNLineListViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        try? realm.write {
            if let model = self.dataSource?[indexPath.row] {
                realm.delete(model)
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alertVC = UIAlertController(title: "操作配置", message: nil, preferredStyle: .alert)
        let editAction = UIAlertAction(title: "修改", style: .default) { (action) in
            if let model = self.dataSource?[indexPath.row] {
                Router.routeToClass(DTVPNLineEditViewController.self, params: ["model": model])
            }
        }
        let useAction = UIAlertAction(title: "选中", style: .default) { [weak self] (action) in
            guard let weakSelf = self else { return }
            if let model = weakSelf.dataSource?[indexPath.row] {
                weakSelf.delegate?.vpnListItemClick(model: model)
                weakSelf.popSelf()
            }
        }
        alertVC.addAction(editAction)
        alertVC.addAction(useAction)
        self.present(alertVC, animated: true, completion: nil)
        
    }
}

extension DTVPNLineListViewController: DTVPNLineEditViewControllerDelegate {
    func saveButtonClick() {
        tableView.reloadData()
    }
}

