import Foundation
import NetworkExtension

public enum ManagerError: Error {
    case invalidProvider
    case vpnStartFail
}

public enum DTVpnStatus {
    case off
    case connecting
    case on
    case disconnecting
}

protocol DTVpnManagerDelegate: class {
    func manager(_ manager: DTVpnManager, didChangeStatus status: DTVpnStatus)
}

class DTVpnManager {
    static let shared = DTVpnManager()
    
    weak var delegate: DTVpnManagerDelegate?

    var observerDidAdd: Bool = false
    
    fileprivate(set) var vpnStatus = DTVpnStatus.off {
        didSet {
            delegate?.manager(self, didChangeStatus: vpnStatus)
        }
    }
    
    fileprivate init() {
        loadProviderManager { [weak self] (manager) in
            if let manager = manager {
                self?.updateVPNStatus(manager)
            }
        }
        addVPNStatusObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 添加vpn的状态的监听
    func addVPNStatusObserver() {
        if observerDidAdd {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
        }
        loadProviderManager { [weak self] (manager) in
            guard let weakSelf = self else { return }
            if let manager = manager {
                weakSelf.observerDidAdd = true
                NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: manager.connection, queue: OperationQueue.main, using: { [weak self] (notification) -> Void in
                    self?.updateVPNStatus(manager)
                })
            }
        }
    }
    
    /// 更新vpn的连接状态
    ///
    /// - Parameter manager: NEDTVpnManager
    func updateVPNStatus(_ manager: NEVPNManager) {
        
        switch manager.connection.status {
        case .connected:
            vpnStatus = .on
        case .connecting, .reasserting://reasserting  暂时无法获得确切状态
            vpnStatus = .connecting
        case .disconnecting:
            vpnStatus = .disconnecting
        case .disconnected, .invalid://invalid 无效状态，配置有错
            vpnStatus = .off
        @unknown default:
            vpnStatus = .off
        }
    }
    
    /// 切换vpn
    open func switchVPN() {
        
    }
}

// load VPN Profiles
extension DTVpnManager {
    
    fileprivate func createProviderManager() -> NETunnelProviderManager {
        let manager = NETunnelProviderManager()
        manager.protocolConfiguration = NETunnelProviderProtocol()
        return manager
    }
    
    func loadAndCreateProviderManager(_ data: DTServerDetailData?, _ complete: @escaping (NETunnelProviderManager?, Error?) -> Void ) {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] (managers, error) in
            guard let managers = managers, let weakSelf = self else { return }
            let manager: NETunnelProviderManager
            if (managers.count > 0) {
                manager = managers[0]
            } else {
                manager = weakSelf.createProviderManager()
            }
            if let protocolConfiguration = manager.protocolConfiguration as? NETunnelProviderProtocol, let data = data {
                protocolConfiguration.providerConfiguration = ["host": data.ip]
            }
            manager.isEnabled = true
            manager.localizedDescription = "YINLI VPN"
            manager.protocolConfiguration?.serverAddress = "127.0.0.1:1080"
            manager.saveToPreferences { error in
                if let error = error {
                    complete(nil, error)
                } else {
                    manager.loadFromPreferences(completionHandler: { (error) -> Void in
                        if let error = error {
                            complete(nil, error)
                        } else {
                            complete(manager, nil)
                        }
                    })
                }
            }
            
        }
    }
    
    func loadProviderManager(_ complete: @escaping (NETunnelProviderManager?) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            if let managers = managers {
                if managers.count > 0 {
                    let manager = managers[0]
                    complete(manager)
                    return
                }
            }
            complete(nil)
        }
    }
}


// MARK: - public func
extension DTVpnManager {
    
    public func isVPNStarted(_ complete: @escaping (Bool, NETunnelProviderManager?) -> Void) {
        loadProviderManager { manager in
            if let manager = manager {
                complete(manager.connection.status == .connected, manager)
            } else {
                complete(false, nil)
            }
        }
    }
    
    public func startVPN(_ data: DTServerDetailData?,_ complete: ((NETunnelProviderManager?, Error?) -> Void)? = nil) {
        startVPNWithOptions(data, complete: complete)
    }
    
    fileprivate func startVPNWithOptions(_ data: DTServerDetailData?, complete: ((NETunnelProviderManager?, Error?) -> Void)? = nil) {
        // Load provider
        loadAndCreateProviderManager(data) { (manager, error) in
            if let error = error {
                complete?(nil, error)
            } else {
                guard let manager = manager else {
                    complete?(nil, ManagerError.invalidProvider)
                    return
                }
                if manager.connection.status == .disconnected || manager.connection.status == .invalid {
                    do {
                        try manager.connection.startVPNTunnel()
                        self.addVPNStatusObserver()
                        complete?(manager, nil)
                    }catch {
                        complete?(nil, error)
                    }
                } else {
                    self.addVPNStatusObserver()
                    complete?(manager, nil)
                }
            }
        }
    }
    
    public func stopVPN() {
        // Stop provider
        loadProviderManager { manager in
            guard let manager = manager else {
                return
            }
            manager.connection.stopVPNTunnel()
        }
    }
}
