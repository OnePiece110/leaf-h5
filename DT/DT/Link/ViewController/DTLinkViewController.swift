//
//  DTLinkViewController.swift
//  DT
//
//  Created by Ye Keyon on 2020/6/30.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire
import Network
import RealmSwift

class DTLinkViewController: DTBaseViewController {
    
    let disposeBag = DisposeBag()
    private let viewModel = DTLinkViewModel()
    private var selectModel: DTServerVOItemData?
    private var reStart: Bool = false
    private var selectProtocolDetail: DTServerDetailData?
    private var isStartConnect = false
    private var isConnected = false
    private let pingQueue = DispatchQueue(label: "com.dt.ping")
    private var isChangeProxyMode = false
    private var ping: SwiftyPing?
    
    var configUrl: URL {
        if let groupFileManagerURL = groupFileManagerURL {
            let url = groupFileManagerURL.appendingPathComponent("running_config.json")
            return url
        }
        return URL(fileURLWithPath: "")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var mode = DTProxyMode.smart
        if let modeNum = DTUserDefaults?.integer(forKey: DTProxyModeKey) {
            mode = DTProxyMode(rawValue: modeNum) ?? .smart
        }
        self.routeModeLabel.text = "路由模式:\(DTProxyMode.matchProxyMode(proxyModel: mode))"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureSubViews()
        navigationItem.title = "引力加速器"
        
        self.configNavigationBar()
        DTVpnManager.shared.delegate = self
        anonymousLogin()
//        self.configTest()
        if let selectRouter = DTUserDefaults?.object(forKey: DTSelectRouter) as? String, !selectRouter.isVaildEmpty() {
            if let model = selectRouter.kj.model(DTServerVOItemData.self) {
                self.selectModel = model
                self.linkNameLabel.text = model.name
                self.changeRipple(ping: model.ping)
            }
        }
        
        if let detail = DTUserDefaults?.object(forKey: DTSelectProtocolDetail) as? String, !detail.isVaildEmpty() {
            if let model = detail.kj.model(DTServerDetailData.self) {
                self.selectProtocolDetail = model
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(proxyModeChange), name: NSNotification.Name(rawValue: PROXY_MODE_CHANGE_Notification), object: nil)
    }
    
    @objc private func proxyModeChange() {
        if DTVpnManager.shared.vpnStatus == .on {
            self.isChangeProxyMode = true
            DTVpnManager.shared.stopVPN()
        }
    }
    
    // 匿名登录,第一版本处理
    private func anonymousLogin() {
        if !DTUser.sharedUser.isLogin {
            DTProgress.showProgress(in: self, message: "加载中...")
            self.viewModel.anonymous().subscribe { [weak self] (result) in
                guard let weakSelf = self else { return }
                DTProgress.dismiss(in: weakSelf)
            } onError: { [weak self] (err) in
                guard let weakSelf = self else { return }
                DTProgress.showError(in: weakSelf, message: "请求失败")
            }.disposed(by: disposeBag)
        }
    }
    
    private func configNavigationBar() {
        let noticeBtn = UIButton(type: .custom)
        noticeBtn.addTarget(self, action: #selector(toLogVC), for: .touchUpInside)
        noticeBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        noticeBtn.setImage(UIImage(named: "icon_link_notice"), for: .normal)
        let noticeItem = UIBarButtonItem(customView: noticeBtn)
        navigationItem.rightBarButtonItems = [noticeItem]
    }
    
    private func configTest() {
        let routeButton = UIButton(type: .custom)
        self.view.addSubview(routeButton)
        routeButton.setTitle("打印路由表", for: .normal)
        routeButton.titleLabel?.font = UIFont.dt.Font(14)
        routeButton.backgroundColor = .red
        routeButton.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(44)
            make.width.equalTo(88)
        }
        routeButton.addTarget(self, action: #selector(writeRoute), for: .touchUpInside)
    }
    
    @objc private func writeRoute() {
        let routerDesc = DTRouter.getRoutingDesc()
        DTFileManager.writeLogData(data: routerDesc?.data(using: .utf8) ?? Data())
    }
    
    @objc private func toLogVC() {
        Router.routeToClass(DTNoticeViewController.self, params: nil, isCheckLogin: true)
    }
    
    private func changeRipple(ping:Double) {
        if ping <= 200 {
            self.rateImageView.image = UIImage(named: "icon_link_rate_very_fast")
            self.rateLabel.text = "超快"
            self.rateLabel.textColor = APPColor.color00B170
            self.rippleView.resetPulsingColor(type: .good)
        } else if (ping >= 200 && ping <= 500) {
            self.rateImageView.image = UIImage(named: "icon_link_rate_fast")
            self.rateLabel.text = "快"
            self.rateLabel.textColor = APPColor.sub
            self.rippleView.resetPulsingColor(type: .general)
        } else {
            self.rateImageView.image = UIImage(named: "icon_link_rate_general")
            self.rateLabel.text = "一般"
            self.rateLabel.textColor = APPColor.colorError
            self.rippleView.resetPulsingColor(type: .bad)
        }
    }
    
    private func updateConnectButtonText(status: DTVpnStatus) {
        DispatchQueue.main.async {
            switch status {
            case .connecting:
                self.rippleView.titleLabel.text = "连接中..."
            case .disconnecting:
                self.rippleView.titleLabel.text = "断开中..."
            case .on:
                DTProgress.dismiss(in: self)
                self.isConnected = true
                self.rippleView.titleLabel.text = "已连接"
                if !self.rippleView.isAnimation {
                    self.rippleView.startAnimation()
                }
            case .off:
                
                if self.reStart, let selectModel = self.selectModel {
                    self.connectClick(model: selectModel, reStart: false)
                } else if (self.isChangeProxyMode) {
                    self.isChangeProxyMode = false
                    self.createConfig(model: self.viewModel.serverData)
                    DTVpnManager.shared.startVPN(self.viewModel.serverData)
                } else {
                    if !self.isStartConnect {
                        self.rippleView.titleLabel.text = "点击连接"
                        DTProgress.dismiss(in: self)
                        self.rippleView.stopAnimation()
                    }
                }
            }
            let userInteractionEnabled = [DTVpnStatus.on, DTVpnStatus.off].contains(status)
            self.rippleView.isUserInteractionEnabled = userInteractionEnabled
            self.linkButton.isUserInteractionEnabled = userInteractionEnabled
            self.rateLabel.isUserInteractionEnabled = userInteractionEnabled
        }
    }
    
    @objc private func connectClick(model: DTServerVOItemData, reStart: Bool) {
        if !DTUser.sharedUser.isLogin {
            self.rippleView.stopAnimation()
            Router.routeToClass(DTLoginViewController.self, params: ["isAddNavigation":true], present: true)
            return
        }
        if self.isStartConnect {
            return
        }
        self.changeRipple(ping: model.ping)
        self.selectModel = model
        self.reStart = reStart
        if (DTVpnManager.shared.vpnStatus == .off) {
            if model.itemId == -1 {
                let serverVOItem = DTServerVOItemData()
                serverVOItem.name = "智能链接"
                serverVOItem.itemId = -1
                self.requestSmartConnect(model: model)
            } else {
                self.connectVPN()
            }
        } else {
            self.rippleView.resetPulsingColor(type: .initial)
            DTVpnManager.shared.stopVPN()
            self.disConnect()
        }
    }
    
    private func disConnect() {
        
    }
    
    private func connectVPN() {
        if let model = self.selectModel {
            if self.isStartConnect {
                return
            }
            self.isStartConnect = true
            self.isConnected = false
            if !self.rippleView.isAnimation {
                self.rippleView.startAnimation()
            }
            debugPrint("开始连接")
            self.viewModel.connect(id: model.itemId).subscribe { [weak self] (json) in
                guard let weakSelf = self else { return }
                debugPrint("开始连接参数获取")
                DTProgress.dismiss(in: weakSelf)
                weakSelf.selectProtocolDetail = json.entry
                weakSelf.isStartConnect = false
                weakSelf.isConnected = true
                
                weakSelf.createConfig(model: weakSelf.viewModel.serverData)
                DTVpnManager.shared.startVPN(weakSelf.viewModel.serverData)
                let jsonString = json.entry.kj.JSONString()
                DTUserDefaults?.set(jsonString, forKey: DTSelectProtocolDetail)
                DTUserDefaults?.synchronize()
            } onError: { [weak self] (error) in
                guard let weakSelf = self else { return }
                DTProgress.showError(in: weakSelf, message: "请求失败")
                weakSelf.isStartConnect = false
                weakSelf.isConnected = false
                weakSelf.rippleView.stopAnimation()
            }.disposed(by: self.disposeBag)
        } else {
            self.isStartConnect = false
            self.rippleView.stopAnimation()
            Router.routeToClass(DTVPNListViewController.self, params: ["delegate": self])
        }
    }
    
    private func configure() -> Void {
        self.navigationItem.title = "连接"
        self.tabBarItem.title = "连接"
    }
    
    private func configureSubViews() {
        self.view.addSubview(titleLabel)
        self.view.addSubview(linkNameLabel)
        self.view.addSubview(rippleView)
        self.view.addSubview(rateView)
        rateView.addSubview(rateImageView)
        rateView.addSubview(rateLabel)
        self.view.addSubview(linkButton)
        self.view.addSubview(routeModeLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(40)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        
        linkNameLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom)
            make.height.equalTo(33)
        }
        
        rateView.snp.makeConstraints { (make) in
            make.top.equalTo(linkNameLabel.snp.bottom)
            make.centerX.equalTo(linkNameLabel)
            make.height.equalTo(25)
        }
        
        rateImageView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.centerY.equalTo(rateView)
            make.size.equalTo(CGSize(width: 23, height: 20))
        }
        
        rateLabel.snp.makeConstraints { (make) in
            make.left.equalTo(rateImageView.snp.right).offset(10)
            make.top.bottom.right.equalTo(0)
        }
        
        rippleView.snp.makeConstraints { (make) in
            make.top.equalTo(rateLabel.snp.bottom).offset(30)
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSize(width: 255, height: 255))
        }
        
        linkButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(rippleView)
            make.top.equalTo(rippleView.snp.bottom).offset(54)
            make.size.equalTo(CGSize(width: 225, height: 48))
        }
        
        routeModeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(linkButton.snp.bottom).offset(15)
            make.centerX.equalTo(linkButton)
            make.height.equalTo(17)
        }
    }
    
    @objc private func linkButtonClick() {
        Router.routeToClass(DTVPNListViewController.self, params: ["delegate": self], isCheckLogin: true)
    }
    
    @objc private func routeModeClick() {
        Router.routeToClass(DTProxyModeViewController.self, isCheckLogin: true)
    }
    
    private lazy var rippleView:DTRippleView = {
        let rippleView = DTRippleView(frame: CGRect(x: 0, y: 0, width: 255, height: 255))
        rippleView.delegate = self
        return rippleView
    }()
    
    private lazy var titleLabel:UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "当前选择线路"
        titleLabel.font = UIFont.dt.Font(14)
        titleLabel.textColor = APPColor.color36BDB8
        return titleLabel
    }()
    
    private lazy var rateView: UIView = {
        let rateView = UIView()
        return rateView
    }()
    
    private lazy var linkNameLabel:UILabel = {
        let linkNameLabel = UILabel()
        linkNameLabel.text = "未选择线路"
        linkNameLabel.font = UIFont.dt.Bold_Font(24)
        linkNameLabel.textColor = APPColor.color36BDB8
        return linkNameLabel
    }()
    
    private lazy var rateImageView: UIImageView = {
        let rateImageView = UIImageView(image: UIImage(named: "icon_link_rate_unlink"))
        return rateImageView
    }()
    
    private lazy var rateLabel:UILabel = {
        let rateLabel = UILabel()
        rateLabel.text = "点击连接"
        rateLabel.font = UIFont.dt.Font(18)
        rateLabel.textColor = UIColor.white
        return rateLabel
    }()
    
    private lazy var linkButton:UIView = {
        let linkButton = UIView()
        linkButton.backgroundColor = APPColor.color0D3A57
        linkButton.layer.cornerRadius = 24
        
        let linkLabel = UILabel()
        linkLabel.text = "选择线路"
        linkLabel.textColor = APPColor.color36BDB8
        linkButton.addSubview(linkLabel)
        linkLabel.snp.makeConstraints { (make) in
            make.centerY.centerX.equalTo(linkButton)
        }
        
        let arrowImg = UIImageView(image: UIImage(named: "icon_link_button_arrow"))
        linkButton.addSubview(arrowImg)
        arrowImg.snp.makeConstraints { (make) in
            make.centerY.equalTo(linkButton)
            make.right.equalTo(-20)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(linkButtonClick))
        linkButton.addGestureRecognizer(tap)
        return linkButton
    }()
    
    private lazy var routeModeLabel: UILabel = {
        let routeModeLabel: UILabel = UILabel().dt
            .text("路由模式:")
            .textColor(APPColor.colorWhite.withAlphaComponent(0.12))
            .font(UIFont.dt.Font(12))
            .viewTarget(add: self, action: #selector(routeModeClick))
            .build
        return routeModeLabel
    }()

}

// MARK: - VpnManagerDelegate
extension DTLinkViewController: DTRippleViewDelegate {
    func rippleViewClick() {
        if let selectModel = self.selectModel {
            self.connectClick(model: selectModel, reStart: false)
        } else {
            Router.routeToClass(DTVPNListViewController.self, params: ["delegate": self])
        }
    }
}

// MARK: - VpnManagerDelegate
extension DTLinkViewController: DTVpnManagerDelegate {
    func manager(_ manager: DTVpnManager, didChangeStatus status: DTVpnStatus) {
        updateConnectButtonText(status: status)
    }
}

//MARK: - DTRouteSelectViewControllerDelegate
extension DTLinkViewController: DTVPNListViewControllerDelegate {
    func routeClick(model: DTServerVOItemData) {
        
        let jsonString = model.kj.JSONString()
        DTUserDefaults?.set(jsonString, forKey: DTSelectRouter)
        DTUserDefaults?.synchronize()
        
        self.linkNameLabel.text = model.name
        if self.selectModel?.itemId != model.itemId || DTVpnManager.shared.vpnStatus == .off {
            self.connectClick(model: model, reStart: self.selectModel?.itemId != model.itemId)
        }
    }
    
    private func requestSmartConnect(model: DTServerVOItemData) {
        if self.isStartConnect {
            return
        }
        self.isStartConnect = true
        self.isConnected = false
        if !self.rippleView.isAnimation {
            self.rippleView.startAnimation()
        }
        self.viewModel.smartConnect().subscribe { [weak self] (json) in
            guard let weakSelf = self else { return }
            DTProgress.dismiss(in: weakSelf)
            weakSelf.selectProtocolDetail = json.entry
            weakSelf.isStartConnect = false
            weakSelf.isConnected = true
            
            weakSelf.createConfig(model: weakSelf.viewModel.serverData)
            DTVpnManager.shared.startVPN(weakSelf.viewModel.serverData)
            let jsonString = json.entry.kj.JSONString()
            DTUserDefaults?.set(jsonString, forKey: DTSelectProtocolDetail)
            DTUserDefaults?.synchronize()
        } onError: { [weak self] (error) in
            guard let weakSelf = self else { return }
            DTProgress.showError(in: weakSelf, message: "请求失败")
            weakSelf.isStartConnect = false
            weakSelf.isConnected = false
            weakSelf.rippleView.stopAnimation()
        }.disposed(by: self.disposeBag)
    }
}
