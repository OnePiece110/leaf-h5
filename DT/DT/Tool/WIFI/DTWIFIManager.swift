//
//  DTWIFIManager.swift
//  DT
//
//  Created by Ye Keyon on 2020/12/31.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import GCDWebServer

class DTWIFIManager:NSObject, GCDWebUploaderDelegate {
    private var webServer: GCDWebUploader?
    private(set) var ip = ""
    private(set) var port = ""
    
    func start() -> Bool {
        
        if let baseURL = DT.groupFileManagerURL {
            let logURL = DTFileManager.createFolder(name: "Log", baseUrl: baseURL, isRmove: false)
            webServer = GCDWebUploader(uploadDirectory: logURL.path)
            if let webServer = webServer {
                webServer.delegate = self
                webServer.allowHiddenItems = true
                webServer.title = "WIFI"
                webServer.prologue = "欢迎使用WIFI管理平台"
                webServer.epilogue = "KongFuVPN"
                if webServer.start() {
                    self.ip = IPHelper.deviceIPAdress()
                    self.port = "\(webServer.port)"
                    return true
                }
            }
        }
        
        guard let currentVC = DTConstants.currentTopViewController() else { return false }
        DTProgress.showError(in: currentVC, message: "服务启动失败")
        return false
        
    }
    
    func stop() {
        webServer?.stop()
        webServer = nil
    }
}
