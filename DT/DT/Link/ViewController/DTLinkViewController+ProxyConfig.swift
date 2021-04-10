//
//  DTLinkViewController+ProxyConfig.swift
//  DT
//
//  Created by Ye Keyon on 2021/4/10.
//  Copyright © 2021 dt. All rights reserved.
//

import Foundation

// MARK: create config
extension DTLinkViewController {
    func createConfig(model: DTServerDetailData) {
        let conf = DTTunnelConfig()
        
        //log
        let log = DTTunnelLog(level: .trace)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
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
        tun.settings?.fakeDnsExclude = [model.domain]
//        tun.settings?.fakeDnsInclude = ["google"]
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
        
        ruleChange(mode: mode, conf: conf)
    }
    
    private func resetConfig() {
        var mode = DTProxyMode.smart
        if let modeNum = DTUserDefaults?.integer(forKey: DTProxyModeKey) {
            mode = DTProxyMode(rawValue: modeNum) ?? .smart
        }
        if let groupFileManagerURL = groupFileManagerURL {
            let url = groupFileManagerURL.appendingPathComponent("running_config.json")
            let configString = try? String(contentsOfFile: url.path, encoding: .utf8)
            let config = configString?.kj.model(DTTunnelConfig.self)
            if let config = config {
                ruleChange(mode: mode, conf: config)
            }
        }
    }
    
    private func ruleChange(mode: DTProxyMode, conf: DTTunnelConfig) {
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
