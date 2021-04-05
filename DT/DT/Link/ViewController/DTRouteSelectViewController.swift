//
//  DTRouteSelectViewController.swift
//  DT
//
//  Created by Ye Keyon on 2020/7/18.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import RxSwift

protocol DTRouteSelectViewControllerDelegate:class {
    func routeClick(model: DTServerVOItemData)
    func smartConnect(model: DTServerVOItemData)
}

class DTRouteSelectViewController: DTBaseViewController,Routable {

    static func initWithParams(params: [String : Any]?) -> UIViewController {
        let vc = DTRouteSelectViewController()
        if let params = params {
            let delegate = params["delegate"]
            if let delegate = delegate as? DTRouteSelectViewControllerDelegate {
                vc.delegate = delegate
            }
        }
        return vc
    }
    
    weak var delegate:DTRouteSelectViewControllerDelegate?
    private var normalRouteTableView:UITableView!
    private var vipRouteTableView:UITableView!
    private var viewModel = DTRouteSelectViewModel()
    private weak var segmentedControl:UISegmentedControl!
    private weak var contentScrollView:UIScrollView!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "线路选择"
        configureSubviews()
        configureData()
    }
    
    func configureSubviews() {
        let segment = UISegmentedControl(items: ["普通线路","VIP线路"])
        segment.backgroundColor = APPColor.colorSubBgView
        segment.tintColor = APPColor.color00B170
        if #available(iOS 13.0, *) {
            segment.selectedSegmentTintColor = APPColor.color00B170
        } else {
            
        }
        segment.selectedSegmentIndex = 0
        segment.setTitleTextAttributes([.foregroundColor:UIColor.white,.font:UIFont.dt.Bold_Font(14)], for: .normal)
        segment.setTitleTextAttributes([.foregroundColor:UIColor.white,.font:UIFont.dt.Bold_Font(14)], for: .selected)
        segment.setTitleTextAttributes([.foregroundColor:UIColor.white,.font:UIFont.dt.Bold_Font(14)], for: .highlighted)
        segment.addTarget(self, action: #selector(segmentValueChange), for: .valueChanged)
        self.segmentedControl = segment
        self.view.addSubview(segment)
        segment.snp.makeConstraints { (make) in
            make.left.equalTo(13)
            make.right.equalTo(-13)
            make.top.equalTo(6)
            make.height.equalTo(40)
        }
        
        let contentScrollView = UIScrollView()
        self.contentScrollView = contentScrollView
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.showsHorizontalScrollIndicator = false
        contentScrollView.isPagingEnabled = true
        contentScrollView.delegate = self;
        self.view.addSubview(contentScrollView)
        contentScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(segment.snp.bottom).offset(20)
            make.left.right.equalTo(0)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(0)
            }
        }
        
        self.normalRouteTableView = createTableView()
        self.vipRouteTableView = createTableView()
        contentScrollView.addSubview(self.normalRouteTableView)
        contentScrollView.addSubview(self.vipRouteTableView)
        
        self.normalRouteTableView.snp.makeConstraints { (make) in
            make.width.height.equalTo(contentScrollView)
            make.left.top.bottom.equalTo(0)
        }
        
        self.vipRouteTableView.snp.makeConstraints { (make) in
            make.left.equalTo(self.normalRouteTableView.snp.right)
            make.width.height.equalTo(contentScrollView)
            make.right.top.bottom.equalTo(0)
        }
    }
    
    func configureData() {
        DTProgress.showProgress(in: self)
        self.viewModel.list().subscribe(onNext: { [weak self] (json) in
            guard let weakSelf = self else { return }
            DTProgress.dismiss(in: weakSelf)
            self?.normalRouteTableView.reloadData()
        }, onError: { [weak self ] (error) in
            guard let weakSelf = self else { return }
            DTProgress.showError(in: weakSelf, message: "请求失败")
        }).disposed(by: disposeBag)
    }
    
    @objc func segmentValueChange() {
        self.contentScrollView.setContentOffset(CGPoint(x: CGFloat(self.segmentedControl.selectedSegmentIndex) * kScreentWidth, y: 0), animated: true)
    }
    
    func createTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 0
        tableView.backgroundColor = .clear
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DTRouteSectionCell.self, forCellReuseIdentifier: "DTRouteSectionCell")
        tableView.register(DTRouteRowCell.self, forCellReuseIdentifier: "DTRouteRowCell")
        return tableView
    }
    
}


extension DTRouteSelectViewController:UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.normalRouteTableView {
            return self.viewModel.normalSectionList.count
        } else {
            return self.viewModel.vipSectionList.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.normalRouteTableView {
            if self.viewModel.normalSectionList[section].isOpen {
                return self.viewModel.normalSectionList[section].serverVOList.count + 1
            } else {
                return 1
            }
        } else {
            if self.viewModel.vipSectionList[section].isOpen {
                return self.viewModel.vipSectionList[section].serverVOList.count + 1
            } else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionModel = self.viewModel.normalSectionList[indexPath.section]
        if indexPath.row == 0 {
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

extension DTRouteSelectViewController:UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 60
        } else {
            return 66
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 6
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.normalRouteTableView {
            if indexPath.row == 0 {
                self.viewModel.normalSectionList[indexPath.section].isOpen = !self.viewModel.normalSectionList[indexPath.section].isOpen
                self.normalRouteTableView.reloadData()
            } else {
                let model = self.viewModel.normalSectionList[indexPath.section].serverVOList[indexPath.row-1]
                self.popSelf()
                self.delegate?.routeClick(model: model)
            }
            
        }
    }
}

extension DTRouteSelectViewController:UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.contentScrollView {
            let index = Int(scrollView.contentOffset.x / kScreentWidth)
            self.segmentedControl.selectedSegmentIndex = index
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == self.contentScrollView {
            let index = Int(scrollView.contentOffset.x / kScreentWidth)
            self.segmentedControl.selectedSegmentIndex = index
        }
    }
}
