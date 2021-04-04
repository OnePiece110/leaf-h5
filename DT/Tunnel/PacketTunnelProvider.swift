//
//  PacketTunnelProvider.swift
//  Tunnel
//
//  Created by Ye Keyon on 2020/8/3.
//Copyright © 2020 dt. All rights reserved.
//

import NetworkExtension

enum DTTunnelError:Error {
    case unValid
}

class PacketTunnelProvider: NEPacketTunnelProvider {
    
    var lastPath:NWPath?
    private var isStartLeaf = false
    override func startTunnel(options: [String : NSObject]? = nil, completionHandler: @escaping (Error?) -> Void) {
        guard let config = (protocolConfiguration as? NETunnelProviderProtocol)?.providerConfiguration else {
            NSLog("[ERROR] No ProtocolConfiguration Found")
            completionHandler(DTTunnelError.unValid)
            return
        }
        
        if let host = config["host"] as? String {

            let newSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "240.0.0.10")
            
            newSettings.ipv4Settings = NEIPv4Settings(addresses: ["240.0.0.1"], subnetMasks: ["255.255.255.0"])
            newSettings.ipv4Settings?.includedRoutes = [NEIPv4Route.default()]
            newSettings.ipv4Settings?.excludedRoutes = [NEIPv4Route(destinationAddress: host, subnetMask: "255.255.255.255")]
            newSettings.proxySettings = nil
            
            newSettings.dnsSettings = NEDNSSettings(servers: ["114.114.114.114", "233.5.5.5", "8.8.8.8"])
            newSettings.mtu = 1500
            setTunnelNetworkSettings(newSettings) { [weak self] error in
                guard error == nil else {
                    completionHandler(error)
                    return
                }
                guard let weakSelf = self else { return }
                let tunFd = weakSelf.packetFlow.value(forKeyPath: "socket.fileDescriptor") as! Int32
                var isSuccess = false
                if let groupFileManagerURL = groupFileManagerURL {
                    let url = groupFileManagerURL.appendingPathComponent("running_config.json")
                    let configString = try? String(contentsOfFile: url.path, encoding: .utf8)
                    let config = configString?.kj.model(DTTunnelConfig.self)
                    if let inbounds = config?.inbounds {
                        for item in inbounds {
                            if item.proto == .tun {
                                item.settings?.fd = tunFd
                            }
                        }
                    }
                    do {
                        try config?.kj.JSONString().write(to: url, atomically: false, encoding: .utf8)
                    } catch {
                        completionHandler(error)
                        NSLog("fialed to write config file \(error)")
                    }
                    if !weakSelf.isStartLeaf {
    //                    weakSelf.addObserver(weakSelf, forKeyPath: "defaultPath", options: .initial, context: nil)
                        isSuccess = true
                        DispatchQueue.global(qos: .userInteractive).async {
                            signal(SIGPIPE, SIG_IGN)
                            weakSelf.isStartLeaf = true
                            run_leaf(url.path)
                        }
                        completionHandler(nil)
                    }
                }
                if !isSuccess {
                    completionHandler(DTTunnelError.unValid)
                }
            }
        } else {
            completionHandler(DTTunnelError.unValid)
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        self.cancelTunnelWithError(nil)
        completionHandler()
    }
        
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }
    
    override func wake() {
        // Add code here to wake up.
    }
    
    /// 监听网络状态，切换不同的网络的时候，需要重新连接
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "defaultPath") {
            if self.defaultPath?.status == .satisfied && self.defaultPath != self.lastPath {
                if (self.lastPath == nil) {
                    self.lastPath = self.defaultPath
                } else {
                    self.lastPath = self.defaultPath
                    NSLog("received network change notifcation")
                    let xSeconds = 0.5
                    DispatchQueue.main.asyncAfter(deadline: .now() + xSeconds) {
                        self.startTunnel(options: nil){ _ in }
                    }
                }
            } else {
                self.lastPath = defaultPath
            }
        }
        
    }
}
