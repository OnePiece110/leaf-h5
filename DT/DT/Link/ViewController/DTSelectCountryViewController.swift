//
//  DTSelectCountryViewController.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/25.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol DTSelectCountryViewControllerDelegate:class {
    func countrySelect(vc:DTSelectCountryViewController, model: DTCountryItemModel)
}

class DTSelectCountryViewController: DTBaseViewController,Routable {

    static func initWithParams(params: [String : Any]?) -> UIViewController {
        let vc = DTSelectCountryViewController()
        if let params = params {
            if let delegate = params["delegate"] as? DTSelectCountryViewControllerDelegate {
                vc.delegate = delegate
            }
        }
        return vc
    }
    
    let disposeBag = DisposeBag()
    let viewModel = DTSelectCountryViewModel()
    var tableView:UITableView!
    weak var delegate:DTSelectCountryViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "选择区号"
        configureSubViews()
        configureData()
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
        tableView.register(DTCountryCell.self, forCellReuseIdentifier: "DTCountryCell")
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
        DTProgress.showProgress(in: self)
        self.viewModel.getCountry().subscribe(on: MainScheduler.instance).subscribe(onNext: { [weak self] (json) in
            guard let weakSelf = self else { return }
            DTProgress.dismiss(in: weakSelf)
            weakSelf.tableView.reloadData()
        }, onError: { [weak self] (error) in
            guard let weakSelf = self else { return }
            DTProgress.dismiss(in: weakSelf)
            debugPrint(error)
        }).disposed(by: disposeBag)
    }

}

extension DTSelectCountryViewController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DTCountryCell", for: indexPath) as! DTCountryCell
        let datalist = self.viewModel.dataList
        cell.readData(model: datalist[indexPath.row], indexPath: indexPath, count: datalist.count)
        return cell
    }
}

extension DTSelectCountryViewController:UITableViewDelegate {
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
        self.delegate?.countrySelect(vc: self, model: self.viewModel.dataList[indexPath.row])
        popSelf()
    }
}
