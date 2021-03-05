//
//  DTTunnelRules.swift
//  Tunnel
//
//  Created by Ye Keyon on 2020/12/28.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import KakaJSON

enum DTRuleType {
    case domain
    case domainSuffix
    case domainKeyword
    case ip
    case external
    case geoip
}

class DTTunnelRule: Convertible {
    private var target = ""
    private var domain: [String]?
    private var domainSuffix: [String]?
    private var domainKeyword: [String]?
    private var ip: [String]?
    private var external: [String]?
    private var geoip: [String]?
    
    required init() {}
    
    func addRule(_ rules: [String], type: DTRuleType, target: String) {
        self.target = target
        switch type {
        case .domain:
            self.domain = rules
        case .domainSuffix:
            self.domainSuffix = rules
        case .domainKeyword:
            self.domainKeyword = rules
        case .ip:
            self.ip = rules
        case .external:
            self.external = rules
        case .geoip:
            self.geoip = rules
        }
    }
}
//
//class DTTunnelDomain: DTTunnelBaseRule {
//
//
//    override func addRule(_ rules: [String]) {
//        self.domain.append(contentsOf: rules)
//    }
//}
//
//class DTTunnelDomainSuffix: DTTunnelBaseRule {
//    var domainSuffix = [String]()
//
//    override func addRule(_ rules: [String]) {
//        self.domainSuffix.append(contentsOf: rules)
//    }
//}
//
//class DTTunnelDomainKeyword: DTTunnelBaseRule {
//    var domainKeyword = [String]()
//
//    override func addRule(_ rules: [String]) {
//        self.domainKeyword.append(contentsOf: rules)
//    }
//}
//
//class DTTunnelIP: DTTunnelBaseRule {
//    var ip = [String]()
//
//    override func addRule(_ rules: [String]) {
//        self.ip.append(contentsOf: rules)
//    }
//}
//
//class DTTunnelGEOIP: DTTunnelBaseRule {
//    var geoip = [String]()
//}
//
//class DTTunnelExternal: DTTunnelBaseRule {
//    var external = [String]()
//}
