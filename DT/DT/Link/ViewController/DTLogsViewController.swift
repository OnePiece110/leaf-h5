//
//  DTLogsViewController.swift
//  DT
//
//  Created by Ye Keyon on 2020/12/31.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

class DTLogsViewController: DTBaseViewController, Routable {

    static func initWithParams(params: [String : Any]?) -> UIViewController {
        let vc = DTLogsViewController()
        return vc
    }
    
    private var tableView:UITableView!
    private var dataSource = [URL]()
    private var wifiManager = DTWIFIManager()
    private var wifi = ""
    
    deinit {
        wifiManager.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "日志列表"
        configureSubViews()
        configureData()
        if wifiManager.start() {
            self.wifi = "网页输入这个地址\nhttp://\(wifiManager.ip):\(wifiManager.port)/"
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
    }
    
    func configureData() {
        if let baseURL = DT.groupFileManagerURL {
            let logURL = DTFileManager.createFolder(name: "Log", baseUrl: baseURL, isRmove: false)
            let enumeratorAtPath = DT.fileManager.enumerator(at: logURL, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)
            if let enumeratorAtPath = enumeratorAtPath {
                for subPath in enumeratorAtPath.allObjects {
                    if let subPath = subPath as? URL {
                        self.dataSource.append(subPath)
                    }
                }
            }
        }
        tableView.reloadData()
    }

}

extension DTLogsViewController:UITableViewDataSource {
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
        cell.textLabel?.text = self.dataSource[indexPath.row].path.components(separatedBy: "/").last
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.textColor = .white;
        label.textAlignment = .center;
        label.font = UIFont.dt.Font(14);
        label.numberOfLines = 0;
        label.text = self.wifi;
        return label
    }
}

extension DTLogsViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let path = self.dataSource[indexPath.row].path
        do {
            try DT.fileManager.removeItem(atPath: path)
            self.dataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
        } catch {
            debugPrint(error)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = self.dataSource[indexPath.row].path
        Router.routeToClass(DTJsonViewController.self, params: ["path": path])
    }
}
