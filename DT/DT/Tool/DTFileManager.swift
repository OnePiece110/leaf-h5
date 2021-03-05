//
//  DTFileManager.swift
//  DT
//
//  Created by Ye Keyon on 2021/1/4.
//  Copyright © 2021 dt. All rights reserved.
//

import UIKit

class DTFileManager {
    
    static func writeLogData(data: Data) {
        if let baseURL = groupFileManagerURL {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let logURL = self.createFolder(name: "Log", baseUrl: baseURL, isRmove: false)
            let fileURL = self.createFile(name: "\(formatter.string(from: Date())).log", baseUrl: logURL)
            
            let fileHandle = try? FileHandle(forUpdating: fileURL)
            if let fileHandle = fileHandle {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        }
    }
    
    static func writeCrashData(data: Data) {
        if let baseURL = groupFileManagerURL {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let logURL = self.createFolder(name: "Log", baseUrl: baseURL, isRmove: false)
            let fileURL = self.createFile(name: "\(formatter.string(from: Date()))_crash.log", baseUrl: logURL)
            
            let fileHandle = try? FileHandle(forUpdating: fileURL)
            if let fileHandle = fileHandle {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        }
    }
    
    static func createFolder(name:String,baseUrl:URL, isRmove: Bool) -> URL {
        let folder = baseUrl.appendingPathComponent(name, isDirectory: true)
        if isRmove {
            try? fileManager.removeItem(atPath: folder.path)
        }
        let exist = fileManager.fileExists(atPath: folder.path)
        if !exist {
            try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true,attributes: nil)
        }
        return folder
    }
    
    static func createFile(name:String,baseUrl:URL) -> URL {
        let filePath = baseUrl.appendingPathComponent(name)
        let exist = fileManager.fileExists(atPath: filePath.path)
        if !exist {
            let data = Data(base64Encoded:"测试" ,options:.ignoreUnknownCharacters)
            let success = fileManager.createFile(atPath: filePath.path, contents: data, attributes: nil)
            debugPrint(success)
        }
        return filePath
    }
    
}
