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
    private var isStartConnect = false
    private var isConnected = false
    
    //test
    private var selectConfigData: DTServerDetailData?
    
    private var configUrl: URL {
        if let groupFileManagerURL = groupFileManagerURL {
            let url = groupFileManagerURL.appendingPathComponent("running_config.json")
            return url
        }
        return URL(fileURLWithPath: "")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureSubViews()
        navigationItem.title = "功夫VPN"
        
        self.configNavigationBar()
//        self.configTest()
        if let selectRouter = DTUserDefaults?.object(forKey: DTSelectRouter) as? String {
            if !selectRouter.isVaildEmpty() {
                if let model = selectRouter.kj.model(DTServerVOItemData.self) {
                    self.selectModel = model
                    self.preSelectModel = model
                    self.linkNameLabel.text = model.name
                    self.pingICMP()
                    if !self.rippleView.isAnimation {
                        self.rippleView.startAnimation()
                    }
                    
                }
            }
        }
        DTVpnManager.shared.delegate = self
    }
    
    func configNavigationBar() {
        let noticeBtn = UIButton(type: .custom)
        noticeBtn.addTarget(self, action: #selector(toLogVC), for: .touchUpInside)
        noticeBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        noticeBtn.setImage(UIImage(named: "icon_link_notice"), for: .normal)
        let noticeItem = UIBarButtonItem(customView: noticeBtn)
        navigationItem.rightBarButtonItems = [noticeItem]
    }
    
    func configTest() {
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
    
    @objc func writeRoute() {
        let routerDesc = DTRouter.getRoutingDesc()
        DTFileManager.writeLogData(data: routerDesc?.data(using: .utf8) ?? Data())
    }
    
    @objc func toLogVC() {
//        Router.routeToClass(DTNoticeViewController.self, params: nil)
        Router.routeToClass(DTLogsViewController.self, params: nil)
    }
    
    @objc func pingICMP() {
        
        rateLabel.text = "正在计算"
        JFPingManager.getFastestAddress(addressList: ["34.117.38.164"]) { [weak self] (address, ping)  in
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
        
//        if !DTUser.sharedUser.isLogin {
//            Router.routeToClass(DTLoginViewController.self, params: ["isAddNavigation":true], present: true)
//            return
//        }
//        if let data = self.selectModel {
//            rateLabel.text = "正在计算"
//            JFPingManager.getFastestAddress(addressList: ["34.117.38.164"]) { [weak self] (address, ping)  in
//                guard let weakSelf = self, let ping = ping else {
//                    return
//                }
//                if ping == 0 {
//                    weakSelf.rateLabel.text = "无信号"
//                } else {
//                    weakSelf.rateLabel.text = String(format: "%.2fms", ping)
//                }
//                weakSelf.changeRipple(ping: ping)
//            }
//        }
    }
    
    func changeRipple(ping:Double) {
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
    
    func updateConnectButtonText(status: DTVpnStatus) {
        DispatchQueue.main.async {
            switch status {
            case .connecting:
                self.rippleView.titleLabel.text = "连接中..."
            case .disconnecting:
                self.rippleView.titleLabel.text = "断开中..."
            case .on:
                DTProgress.dismiss(in: self)
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
    
    @objc func connectClick() {
//        if !DTUser.sharedUser.isLogin {
//            self.rippleView.stopAnimation()
//            Router.routeToClass(DTLoginViewController.self, params: ["isAddNavigation":true], present: true)
//            return
//        }
//        if self.isStartConnect {
//            return
//        }
        if !self.rippleView.isAnimation {
            self.rippleView.startAnimation()
        }
        if (DTVpnManager.shared.vpnStatus == .off) {
            self.connectVPN()
        } else {
            DTVpnManager.shared.stopVPN()
        }
    }
    
    func connectVPN() {        
        Router.routeToClass(DTVPNLineListViewController.self, params: ["delegate": self])
        
//        DTProgress.dismiss(in: self)
//        self.preSelectModel = self.selectModel
//        self.isStartConnect = false
//        self.isConnected = true
//        self.pingICMP()
        /*
         伪装域名/SNI：tele4.mytube.vip，端口：443，用户ID：2b64afed-4ce3-4513-b6d0-5f6c69170ebd
         */
//        let data = DTServerDetailData()
//        data.domain = "tele5.mytube.vip"
//        data.passwd = "b0b05be4-6858-4be2-9bdb-2f3686372bc3"
//        data.port = 443
//        data.ip = "34.117.38.164"
//        data.path = "/eorpaws"
        
//        data.domain = "beta2.mytube.vip"
//        data.passwd = "d274521c-7363-4fc4-a5db-bb61facf1642"
//        data.port = 443
//        data.ip = "172.67.163.14"
//        data.path = "/bcdcws"
//        DTVpnManager.shared.startVPN(data)
        
//        if let model = self.selectModel {
//            self.isStartConnect = true
//            self.isConnected = false
//            DTProgress.showProgress(in: self)
//            self.viewModel.connect(id: model.itemId).subscribe { [weak self] (json) in
//                guard let weakSelf = self else { return }
//                DTProgress.dismiss(in: weakSelf)
//                weakSelf.preSelectModel = weakSelf.selectModel
//                weakSelf.isStartConnect = false
//                weakSelf.isConnected = true
//                weakSelf.pingICMP()
//                DTVpnManager.shared.startVPN(weakSelf.viewModel.serverData)
//            } onError: { [weak self] (error) in
//                guard let weakSelf = self else { return }
//                DTProgress.dismiss(in: weakSelf)
//                DTProgress.showError(in: weakSelf, message: "请求失败")
//                weakSelf.isStartConnect = false
//                weakSelf.isConnected = false
//                weakSelf.rippleView.stopAnimation()
//            }.disposed(by: self.disposeBag)
//        } else {
//            self.isStartConnect = false
//            self.rippleView.stopAnimation()
//            Router.routeToClass(DTVPNListViewController.self, params: ["delegate": self])
//        }
    }
    
    func configure() -> Void {
        self.navigationItem.title = "连接"
        self.tabBarItem.title = "连接"
    }
    
    func configureSubViews() {
        self.view.addSubview(titleLabel)
        self.view.addSubview(linkNameLabel)
        self.view.addSubview(rippleView)
        self.view.addSubview(rateLabel)
        self.view.addSubview(linkButton)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(40)
            make.centerX.equalTo(rippleView)
        }
        
        linkNameLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom)
        }
        
        rateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(linkNameLabel.snp.bottom)
            make.centerX.equalTo(self.view)
        }
        
        rippleView.snp.makeConstraints { (make) in
            make.top.equalTo(rateLabel.snp.bottom).offset(40)
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSize(width: 225, height: 225))
        }
        
        linkButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(rippleView)
            make.top.equalTo(rippleView.snp.bottom).offset(54)
            make.size.equalTo(CGSize(width: 225, height: 48))
        }
    }
    
    @objc func linkButtonClick() {
        Router.routeToClass(DTVPNListViewController.self, params: ["delegate": self], isCheckLogin: true)
    }
    
    lazy var rippleView:DTRippleView = {
        let rippleView = DTRippleView(frame: CGRect(x: 0, y: 0, width: 225, height: 225))
        rippleView.delegate = self
        return rippleView
    }()
    
    lazy var titleLabel:UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "当前选择线路"
        titleLabel.font = UIFont.dt.Font(14)
        titleLabel.textColor = APPColor.color36BDB8
        return titleLabel
    }()
    
    lazy var linkNameLabel:UILabel = {
        let linkNameLabel = UILabel()
        linkNameLabel.text = "未选择线路"
        linkNameLabel.font = UIFont.dt.Bold_Font(24)
        linkNameLabel.textColor = APPColor.color36BDB8
        return linkNameLabel
    }()
    
    lazy var rateLabel:UILabel = {
        let rateLabel = UILabel()
        rateLabel.text = "未连接"
        rateLabel.font = UIFont.dt.Font(18)
        rateLabel.textColor = UIColor.white
        let rateTap = UITapGestureRecognizer(target: self, action: #selector(pingICMP))
        rateLabel.isUserInteractionEnabled = true
        rateLabel.addGestureRecognizer(rateTap)
        return rateLabel
    }()
    
    lazy var linkButton:UIView = {
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
}


// MARK: create config
extension DTLinkViewController {
    func createConfig(domain: String, password:String, port: Int, path: String?, proto: String?, host: String?) {
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
        let dnsServer = DTTunnelDNS(servers: ["114.114.114.114", "233.5.5.5"])
        conf.dns = dnsServer
        
        //inbounds
        let tun = DTTunnelInbounds(fd: 4)
//        tun.settings?.fakeDnsExclude = ["baidu"]
        conf.inbounds.append(tun)
        
        //outbounds
        var pro: DTOutboundsProtocol = .vless
        if let proto = proto {
            pro = DTOutboundsProtocol(rawValue: proto) ?? .vless
        }
        
        var mode = DTProxyMode.smart
        if let modeNum = DTUserDefaults?.integer(forKey: DTProxyModeKey) {
            mode = DTProxyMode(rawValue: modeNum) ?? .smart
        }
        
        if pro == .shadowsocks {
            let ss = DTTunnelOutbounds(proto: pro)
            ss.settings?.address = domain
            ss.settings?.password = password
            ss.settings?.method = "aes-128-gcm"
            ss.settings?.port = port
            ss.tag = "failover_out"
            conf.outbounds.append(ss)
        } else {
            let chain = DTTunnelOutbounds(proto: .chain)
            chain.settings?.actors?.append(contentsOf: ["tls", "proto"])
            chain.tag = "failover_out"
            conf.outbounds.append(chain)
            
            let tls = DTTunnelOutbounds(proto: .tls)
            tls.settings?.alpn = ["http/1.1"]
            tls.settings?.serverName = domain
            tls.tag = "tls"
            conf.outbounds.append(tls)
            
            let proto = DTTunnelOutbounds(proto: pro)
            proto.configSetting(domain: domain, password: password, port: port)
            proto.tag = "proto"
            conf.outbounds.append(proto)
            
            if let path = path, path.count > 1 {
                let ws = DTTunnelOutbounds(proto: .ws)
                ws.settings?.path = path
                ws.tag = "ws"
                if let host = host {
                    ws.settings?.headers = ["Host": host]
                }
                conf.outbounds.append(ws)
                chain.settings?.actors = ["tls", "ws", "proto"]
            }
        }
        
        let direct = DTTunnelOutbounds(proto: .direct)
        conf.outbounds.append(direct)
        
        //rules
        var rules = [DTTunnelRule]()
        
        let domainFailover = self.addRule(withType: .domain, fileName: "domain_failover", target: "failover_out")
        let domainDirect = self.addRule(withType: .domain, fileName: "domain_direct", target: "direct_out")
        rules.append(contentsOf: [domainDirect, domainFailover])

        let domianSuffixDirect = self.addRule(withType: .domainSuffix, fileName: "domain_suffix_direct", target: "direct_out")
        let domianSuffixFailover = self.addRule(withType: .domainSuffix, fileName: "domain_suffix_failover", target: "failover_out")
        rules.append(contentsOf: [domianSuffixDirect, domianSuffixFailover])

        let domianKeywordDirect = self.addRule(withType: .domainKeyword, fileName: "domain_keyword_direct", target: "direct_out")
        let domianKeywordFailover = self.addRule(withType: .domainKeyword, fileName: "domain_keyword_failover", target: "failover_out")
        rules.append(contentsOf: [domianKeywordDirect, domianKeywordFailover])

        let ipDirect = self.addRule(withType: .ip, fileName: "domain_ip_direct", target: "direct_out")
        let ipFailover = self.addRule(withType: .ip, fileName: "domain_ip_failover", target: "failover_out")
        rules.append(contentsOf: [ipDirect, ipFailover])


        let external = DTTunnelRule()
        external.addRule(["site:cn"], type: .external, target: "direct_out")

        let externalMMDB = DTTunnelRule()
        externalMMDB.addRule(["mmdb:cn"], type: .external, target: "direct_out")

        rules.append(contentsOf: [external, externalMMDB])

        conf.rules.append(contentsOf: rules)
        
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

extension DTLinkViewController: DTVPNLineListViewControllerDelegate {
    func vpnListItemClick(model: DTVPNLineModel) {
        self.isStartConnect = false
        self.isConnected = true
        self.pingICMP()
        let data = DTServerDetailData()
        data.ip = "34.117.38.164"
        self.createConfig(domain: model.domain, password: model.passwd, port: model.port, path: model.path, proto: model.proto, host: model.host)
        DTVpnManager.shared.startVPN(data)
    }
}
