//
//  AppDelegate.swift
//  DT
//
//  Created by Ye Keyon on 2020/6/30.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Alamofire
import RxSwift
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let net = NetworkReachabilityManager()
    let disposeBag = DisposeBag()
    var isStartDown = false
    var downloadFiles = ["domain_direct.txt",
                         "domain_drop.txt",
                         "domain_failover.txt",
                         "domain_ip_direct.txt",
                         "domain_ip_drop.txt",
                         "domain_ip_failover.txt",
                         "domain_keyword_direct.txt",
                         "domain_keyword_drop.txt",
                         "domain_keyword_failover.txt",
                         "domain_suffix_direct.txt",
                         "domain_suffix_drop.txt",
                         "domain_suffix_failover.txt"]
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        if let userProfile = DTUserDefaults?.object(forKey: DTUserProfile) as? String {
            if !userProfile.isVaildEmpty() {
                if let model = userProfile.kj.model(DTUser.self) {
                    DTUser.sharedUser.configureData(model: model)
                }
            }
        }
        
        self.clearLaunchScreenCache()
        
        net?.startListening(onUpdatePerforming: { [weak self] (status) in
            guard let weakSelf = self else { return }
            if weakSelf.net?.isReachable ?? false {
                switch status {
                case .notReachable:
                    debugPrint("the noework is not reachable")
                case .unknown:
                    debugPrint("It is unknown whether the network is reachable")
                case .reachable(.ethernetOrWiFi):
                    debugPrint("通过WiFi链接")
                case .reachable(.cellular):
                    debugPrint("通过移动网络链接")
                }
            } else {
                debugPrint("网络不可用")
            }
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let tabBarVC = DTTabBarViewController()
            self.window?.rootViewController = tabBarVC
            self.window?.makeKeyAndVisible()
        }
        
        CrashEye.shareInstance.add(delegate: self)
        
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
            })

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        return true
    }
    
    
    func clearLaunchScreenCache() {
        do {
            try FileManager.default.removeItem(atPath: NSHomeDirectory()+"/Library/SplashBoard")
        } catch {
            print("Failed to delete launch screen cache: \(error)")
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        startDownLoadAllFile()
    }
    
    func startDownLoadAllFile() {
        if self.isStartDown || !Date().isAfterHalfDay() {
            return
        }
        self.isStartDown = true
        var downLoadObsebables = [Observable<Data>]()
        for fileName in self.downloadFiles {
            downLoadObsebables.append(self.startDownLoadFile(fileName: fileName))
        }
        Observable.zip(downLoadObsebables).subscribe { [weak self] (downLoadDatas) in
            debugPrint("全部下载完成")
            guard let weakSelf = self else { return }
            weakSelf.isStartDown = false
        } onError: { [weak self] (error) in
            guard let weakSelf = self else { return }
            debugPrint(error)
            weakSelf.isStartDown = false
        }.disposed(by: disposeBag)

    }
    
    func startDownLoadFile(fileName: String) -> Observable<Data> {
        let domainDirect = DTHttp.share.downloadFile(url: fileName).do { (data) in
            if let url = DT.groupFileManagerURL {
                let ruleURL = DTFileManager.createFolder(name: "rules", baseUrl: url, isRmove: true)
                let domainDirectURL = ruleURL.appendingPathComponent(fileName)
                try? data.write(to: domainDirectURL)
            }
        } onError: { (error) in
            debugPrint(error)
        }

        
        return domainDirect
    }
    
    deinit {
        net?.stopListening()
    }

}

extension AppDelegate: CrashCensorDelegate {
    func crashEyeDidCatchCrash(model: CrashModel) {
        let string = "名字:" + model.name + "\r" + "原因:" + model.reason + "\r" + "app信息:" + model.appinfo + "\r" + "堆栈信息:" + model.callStack
        DTFileManager.writeCrashData(data: string.data(using: .utf8) ?? Data())
    }
}

