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
    private var preSelectModel: DTServerVOItemData?
    private var selectProtocolDetail: DTServerDetailData?
    private var isStartConnect = false
    private var isConnected = false
    private let pingQueue = DispatchQueue(label: "com.dt.ping")
    
    private var configUrl: URL {
        if let groupFileManagerURL = groupFileManagerURL {
            let url = groupFileManagerURL.appendingPathComponent("running_config.json")
            return url
        }
        return URL(fileURLWithPath: "")
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
                self.preSelectModel = model
                self.linkNameLabel.text = model.name
            }
        }
        
        if let detail = DTUserDefaults?.object(forKey: DTSelectProtocolDetail) as? String, !detail.isVaildEmpty() {
            if let model = detail.kj.model(DTServerDetailData.self) {
                self.selectProtocolDetail = model
                self.pingICMP()
                if !self.rippleView.isAnimation {
                    self.rippleView.startAnimation()
                }
            }
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
//        Router.routeToClass(DTLogsViewController.self, params: nil)
    }
    
    @objc private func pingICMP() {
        if let data = self.selectProtocolDetail {
            rateLabel.text = "正在计算"
            JFPingManager.getFastestAddress(addressList: [data.ip]) { [weak self] (address, ping)  in
                guard let weakSelf = self, let ping = ping else {
                    return
                }
                if ping == 0 {
                    weakSelf.rateLabel.text = "无信号"
                } else {
                    weakSelf.rateLabel.text = String(format: "%.2fms", ping)
                }
                weakSelf.changeRipple(ping: ping)
            }
        }
    }
    
    private func changeRipple(ping:Double) {
        if !self.isConnected {
            return
        }
        if ping <= 50 {
            self.rippleView.resetPulsingColor(type: .good)
        } else if (ping >= 50 && ping <= 200) {
            self.rippleView.resetPulsingColor(type: .general)
        } else {
            self.rippleView.resetPulsingColor(type: .bad)
        }
        rateLabel.textColor = UIColor.white
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
            case .off:
                self.rippleView.titleLabel.text = "未连接"
                self.rippleView.resetPulsingColor(type: .initial)
                if self.preSelectModel?.itemId != self.selectModel?.itemId {
                    self.connectVPN()
                } else {
                    DTProgress.dismiss(in: self)
                    self.rippleView.stopAnimation()
                }
            }
            let userInteractionEnabled = [DTVpnStatus.on, DTVpnStatus.off].contains(status)
            self.rippleView.isUserInteractionEnabled = userInteractionEnabled
            self.linkButton.isUserInteractionEnabled = userInteractionEnabled
            self.rateLabel.isUserInteractionEnabled = userInteractionEnabled
        }
    }
    
    @objc private func connectClick() {
        if !DTUser.sharedUser.isLogin {
            self.rippleView.stopAnimation()
            Router.routeToClass(DTLoginViewController.self, params: ["isAddNavigation":true], present: true)
            return
        }
        if self.isStartConnect {
            return
        }
        if (DTVpnManager.shared.vpnStatus == .off) {
            self.connectVPN()
        } else {
            DTVpnManager.shared.stopVPN()
            self.disConnect()
        }
    }
    
    private func disConnect() {
//        if let model = self.selectModel {
//            self.viewModel.disConnect(id: model.itemId).subscribe { (json) in
//                DTUserDefaults?.set(nil, forKey: DTSelectProtocolDetail)
//                DTUserDefaults?.synchronize()
//            } onError: { [weak self] (error) in
//                guard let weakSelf = self else { return }
//                DTProgress.showError(in: weakSelf, message: "请求失败")
//            }.disposed(by: self.disposeBag)
//        }
        DTUserDefaults?.set(nil, forKey: DTSelectProtocolDetail)
        DTUserDefaults?.synchronize()
    }
    
    private func connectVPN() {
        if let model = self.selectModel {
            if self.isStartConnect {
                return
            }
            self.isStartConnect = true
            self.isConnected = false
            DTProgress.showProgress(in: self)
            debugPrint("开始连接")
            self.viewModel.connect(id: model.itemId).subscribe { [weak self] (json) in
                guard let weakSelf = self else { return }
                debugPrint("开始连接参数获取")
                DTProgress.dismiss(in: weakSelf)
                weakSelf.selectProtocolDetail = json.entry
                weakSelf.preSelectModel = weakSelf.selectModel
                weakSelf.isStartConnect = false
                weakSelf.isConnected = true
                weakSelf.pingICMP()
                if !weakSelf.rippleView.isAnimation {
                    weakSelf.rippleView.startAnimation()
                }
                
                weakSelf.createConfig(model: weakSelf.viewModel.serverData)
                DTVpnManager.shared.startVPN(weakSelf.viewModel.serverData)
                let jsonString = json.entry.kj.JSONString()
                DTUserDefaults?.set(jsonString, forKey: DTSelectProtocolDetail)
                DTUserDefaults?.synchronize()
            } onError: { [weak self] (error) in
                guard let weakSelf = self else { return }
                DTProgress.dismiss(in: weakSelf)
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
        self.view.addSubview(rateLabel)
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
        
        rateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(linkNameLabel.snp.bottom)
            make.centerX.equalTo(linkNameLabel)
            make.height.equalTo(25)
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
    
    private lazy var linkNameLabel:UILabel = {
        let linkNameLabel = UILabel()
        linkNameLabel.text = "未选择线路"
        linkNameLabel.font = UIFont.dt.Bold_Font(24)
        linkNameLabel.textColor = APPColor.color36BDB8
        return linkNameLabel
    }()
    
    private lazy var rateLabel:UILabel = {
        let rateLabel = UILabel()
        rateLabel.text = "未连接"
        rateLabel.font = UIFont.dt.Font(18)
        rateLabel.textColor = UIColor.white
        let rateTap = UITapGestureRecognizer(target: self, action: #selector(pingICMP))
        rateLabel.isUserInteractionEnabled = true
        rateLabel.addGestureRecognizer(rateTap)
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
        self.connectClick()
    }
}

// MARK: - VpnManagerDelegate
extension DTLinkViewController: DTVpnManagerDelegate {
    func manager(_ manager: DTVpnManager, didChangeStatus status: DTVpnStatus) {
        updateConnectButtonText(status: status)
    }
}

//MARK: - DTRouteSelectViewControllerDelegate
extension DTLinkViewController: DTRouteSelectViewControllerDelegate {
    func routeClick(model: DTServerVOItemData) {
        
        let jsonString = model.kj.JSONString()
        DTUserDefaults?.set(jsonString, forKey: DTSelectRouter)
        DTUserDefaults?.synchronize()
        
        self.selectModel = model
        self.linkNameLabel.text = model.name
        if self.selectModel?.itemId != self.preSelectModel?.itemId || DTVpnManager.shared.vpnStatus == .off {
            self.connectClick()
        }
    }
    
    func smartConnect(model: DTServerVOItemData) {
        
        let jsonString = model.kj.JSONString()
        DTUserDefaults?.set(jsonString, forKey: DTSelectRouter)
        DTUserDefaults?.synchronize()
        
        self.selectModel = model
        self.linkNameLabel.text = model.name
        
        self.viewModel.smartConnect().subscribe { [weak self] (json) in
            guard let weakSelf = self else { return }
            DTProgress.dismiss(in: weakSelf)
            weakSelf.selectProtocolDetail = json.entry
            weakSelf.preSelectModel = weakSelf.selectModel
            weakSelf.isStartConnect = false
            weakSelf.isConnected = true
            weakSelf.pingICMP()
            if !weakSelf.rippleView.isAnimation {
                weakSelf.rippleView.startAnimation()
            }
            weakSelf.createConfig(model: weakSelf.viewModel.serverData)
            DTVpnManager.shared.startVPN(weakSelf.viewModel.serverData)
            let jsonString = json.entry.kj.JSONString()
            DTUserDefaults?.set(jsonString, forKey: DTSelectProtocolDetail)
            DTUserDefaults?.synchronize()
        } onError: { [weak self] (error) in
            guard let weakSelf = self else { return }
            DTProgress.dismiss(in: weakSelf)
            DTProgress.showError(in: weakSelf, message: "请求失败")
            weakSelf.isStartConnect = false
            weakSelf.isConnected = false
            weakSelf.rippleView.stopAnimation()
        }.disposed(by: self.disposeBag)
    }
}


// MARK: create config
extension DTLinkViewController {
    func createConfig(model: DTServerDetailData) {
        let conf = DTTunnelConfig()
        
        //log
        let log = DTTunnelLog(level: .trace)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let baseURL = groupFileManagerURL {
            let logURL = DTFileManager.createFolder(name: "Log", baseUrl: baseURL, isRmove: false)
            let fileURL = DTFileManager.createFile(name: "\(formatter.string(from: Date())).log", baseUrl: logURL)
            log.output = fileURL.path
        }
        conf.log = log
        
        //dns
        let dnsServer = DTTunnelDNS(servers: ["114.114.114.114", "233.5.5.5", "8.8.8.8"])
        conf.dns = dnsServer
        
        //inbounds
        let tun = DTTunnelInbounds(fd: 4)
//        tun.settings?.fakeDnsExclude = [model.domain]
        tun.settings?.fakeDnsInclude = ["google"]
        conf.inbounds.append(tun)
        
        //outbounds
        let pro: DTOutboundsProtocol = DTOutboundsProtocol.matchPtotocol(proto: model.proto)
        
        var mode = DTProxyMode.smart
        if let modeNum = DTUserDefaults?.integer(forKey: DTProxyModeKey) {
            mode = DTProxyMode(rawValue: modeNum) ?? .smart
        }
        
        if mode == .smart || mode == .direct {
            let direct = DTTunnelOutbounds(proto: .direct)
            conf.outbounds.append(direct)
        }
        
        if mode == .proxy || mode == .smart {
            if pro == .shadowsocks {
                let ss = DTTunnelOutbounds(proto: pro)
                ss.settings?.address = model.domain
                ss.settings?.password = model.passwd
                ss.settings?.method = model.algorithm
                ss.settings?.port = model.port
                ss.tag = "failover_out"
                conf.outbounds.append(ss)
            } else {
                let chain = DTTunnelOutbounds(proto: .chain)
                chain.tag = "failover_out"
                conf.outbounds.append(chain)
                
                // tls协议
                let tls = DTTunnelOutbounds(proto: .tls)
                if !model.sni.isVaildEmpty() {
                    tls.settings?.serverName = model.sni
                }
                tls.tag = "tls"
                tls.settings?.alpn = ["http/1.1"]
                conf.outbounds.append(tls)
                chain.settings?.actors?.append("tls")
                
                // h2协议
                let h2 = DTTunnelOutbounds(proto: .h2)
                if model.h2Path.count > 1 {
                    tls.settings?.alpn = ["h2"]
                    h2.settings?.path = model.h2Path
                    if model.h2Host.count > 0 {
                        h2.settings?.host = model.h2Host
                    }
                    conf.outbounds.append(h2)
                    chain.settings?.actors?.append("h2")
                }
                
                // ws协议
                if model.path.count > 1 {
                    let ws = DTTunnelOutbounds(proto: .ws)
                    ws.settings?.path = model.path
                    ws.tag = "ws"
                    if model.host.count > 0 {
                        ws.settings?.headers = ["Host": model.host]
                    }
                    conf.outbounds.append(ws)
                    chain.settings?.actors?.append("ws")
                }
                
                // 协议实例 包括vless trojan vmess
                let proto = DTTunnelOutbounds(proto: pro)
                proto.configSetting(model: model)
                if !model.algorithm.isVaildEmpty() {
                    proto.settings?.method = model.algorithm
                }
                //aead 加密
                if model.security.count > 0 {
                    proto.settings?.security = model.security.lowercased()
                }
                if model.securityPassword.count > 0 {
                    proto.settings?.security_password = model.securityPassword
                }
                proto.tag = "proto"
                conf.outbounds.append(proto)
                chain.settings?.actors?.append("proto")
                
            }
        }
        
        //rules
        var rules = [DTTunnelRule]()
        
        let domainFailover = self.addRule(withType: .domain, fileName: "domain_failover", target: "failover_out")
        let domainDirect = self.addRule(withType: .domain, fileName: "domain_direct", target: "direct_out")
        rules.append(contentsOf: [domainFailover, domainDirect])

        let domianSuffixDirect = self.addRule(withType: .domainSuffix, fileName: "domain_suffix_direct", target: "direct_out")
        let domianSuffixFailover = self.addRule(withType: .domainSuffix, fileName: "domain_suffix_failover", target: "failover_out")
        rules.append(contentsOf: [domianSuffixFailover, domianSuffixDirect])

        let domianKeywordDirect = self.addRule(withType: .domainKeyword, fileName: "domain_keyword_direct", target: "direct_out")
        let domianKeywordFailover = self.addRule(withType: .domainKeyword, fileName: "domain_keyword_failover", target: "failover_out")
        rules.append(contentsOf: [domianKeywordFailover, domianKeywordDirect])

        let ipDirect = self.addRule(withType: .ip, fileName: "domain_ip_direct", target: "direct_out")
        let ipFailover = self.addRule(withType: .ip, fileName: "domain_ip_failover", target: "failover_out")
        rules.append(contentsOf: [ipFailover, ipDirect])

        let external = DTTunnelRule()
        external.addRule(["site:!cn"], type: .external, target: "failover_out")

        let externalMMDB = DTTunnelRule()
        externalMMDB.addRule(["mmdb:!cn"], type: .external, target: "failover_out")

        rules.append(contentsOf: [external, externalMMDB])
        
        if mode == .smart {
            conf.rules = rules
        } else {
            let rule = DTTunnelRule()
            rule.addRule([""], type: .domainKeyword, target: mode == .direct ? "direct_out" : "failover_out")
            conf.rules = [rule]
        }
        
        do {
            try conf.kj.JSONString().write(to: configUrl, atomically: false, encoding: .utf8)
        } catch {
            NSLog("fialed to write config file \(error)")
        }
    }
    
    func addRule(withType type: DTRuleType, fileName: String, target: String) -> DTTunnelRule {
        let ruleModel = DTTunnelRule()
        
        var rulePath = ""
        let (url, isValid) = self.isValidFileName(fileName: fileName, ofType: "txt")
        if isValid, let url = url {
            rulePath = url.path
        } else {
            rulePath = Bundle.main.path(forResource: fileName, ofType: "txt")!
        }
        do {
            let ipConetont = try String(contentsOfFile: rulePath, encoding: .utf8)
            var rules = ipConetont.components(separatedBy: "\n")
            rules.removeLast()
            ruleModel.addRule((rules), type: type, target: target)
        } catch {
            print(String(describing: error))
        }
        
        return ruleModel
    }
    
    func isValidFileName(fileName: String,ofType type: String) -> (URL?,Bool) {
        let path = groupFileManagerURL?.appendingPathComponent("rules/\(fileName).\(type)")
        if let path = path {
            if DT.fileManager.fileExists(atPath: path.path) {
                let fileData = try? Data(contentsOf: path)
                if let fileData = fileData {
                    return (path, fileData.count > 0)
                }
            }
        }
        return (nil, false)
    }
}
