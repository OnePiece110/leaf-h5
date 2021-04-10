//
//  MSHttpClient.swift
//  Miaosu
//
//  Created by 叶金永 on 2019/1/11.
//  Copyright © 2019 Keyon. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift
import KakaJSON
import MFSIdentifier

enum DTError:Error {
    case StatusFalse
}

class DTHttp {
	
	private var session: Session!
    
	public static let share:DTHttp = {
		let data = DTHttp()
        let queue = DispatchQueue(label: "com.alphaWisdom.gft.request")
        let config = URLSessionConfiguration.default
        let delegate = SessionDelegate()
        data.session = Session(configuration: config, delegate: delegate, rootQueue: queue)
		return data
	}()
	
    @discardableResult
    func get<T: BaseResult>(url:String,parameters params:[String:Any]?) -> Observable<T> {
        return Observable<T>.create { [weak self] (observer) -> Disposable in
            guard let weakSelf = self else { return Disposables.create() }
            var headersParams = [String: String]()
            if DTUser.sharedUser.isLogin {
                headersParams["token"] = DTUser.sharedUser.token
            }
            headersParams["deviceId"] = MFSIdentifier.deviceID()
            headersParams["version"] = APPSystem.currentVersion
            let headers = HTTPHeaders(headersParams)
            let dataRequest = weakSelf.session.request(baseUrl + url, method: .get, parameters: params, headers: headers).responseString { (response) in
                switch response.result {
                case .success(let jsonValue):
                    debugPrint(jsonValue)
                    let json = jsonValue.kj.model(T.self)
                    if let json = json, let status = json.status, status {
                        observer.onNext(json)
                    } else {
                        observer.onError(DTError.StatusFalse)
                    }
                case .failure(let err):
                    debugPrint(err)
                    observer.onError(err)
                }
                observer.onCompleted()
            }
            return Disposables.create {
                dataRequest.cancel()
                debugPrint("request Disposables")
            }
        }
	}
	
    @discardableResult
    func post<T: BaseResult>(url:String, parameters params:[String:Any]?) -> Observable<T> {
        return Observable<T>.create { [weak self] (observer) -> Disposable in
            guard let weakSelf = self else { return Disposables.create() }
            var headersParams = [String: String]()
            if DTUser.sharedUser.isLogin {
                headersParams["token"] = DTUser.sharedUser.token
            }
            headersParams["deviceId"] = MFSIdentifier.deviceID()
            headersParams["version"] = APPSystem.currentVersion
            let headers = HTTPHeaders(headersParams)
            let dataRequest = weakSelf.session.request(baseUrl + url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseString { (response) in
                switch response.result {
                case .success(let jsonValue):
                    debugPrint(jsonValue)
                    let json = jsonValue.kj.model(T.self)
                    if let json = json, let status = json.status, status {
                        observer.onNext(json)
                    } else {
                        observer.onError(DTError.StatusFalse)
                    }
                case .failure(let err):
                    observer.onError(err)
                    
                }
                observer.onCompleted()
            }
            return Disposables.create {
                dataRequest.cancel()
                debugPrint("request Disposables")
            }
        }
    }
	
    func uploadImage<T: BaseResult>(_ data:Data, fileName: String, mimeType: String, uploadBlock:@escaping (_ json:T?,_ error:Error?) -> Void) -> Observable<T> {
        var headersParams = [String: String]()
        if DTUser.sharedUser.isLogin {
            headersParams["token"] = DTUser.sharedUser.token
        }
        headersParams["deviceId"] = MFSIdentifier.deviceID()
        headersParams["version"] = APPSystem.currentVersion
        let headers = HTTPHeaders(headersParams)
        return Observable<T>.create { [weak self] (observer) -> Disposable in
            guard let weakSelf = self else { return Disposables.create() }
            let dataRequest = weakSelf.session.upload(multipartFormData: { (multipartFormData) in
                multipartFormData.append(data, withName: "file", fileName: fileName, mimeType: mimeType)
            }, to: baseUrl + "lighthouse/upload/file", headers: headers).uploadProgress { (progress) in
                debugPrint("图片上传进度: \(progress.fractionCompleted)")
            }.responseString(completionHandler: { (response) in
                debugPrint(response)
                switch response.result {
                case .success(let jsonValue):
                    let json = jsonValue.kj.model(T.self)
                    if let json = json {
                        observer.onNext(json)
                    } else {
                        observer.onError(DTError.StatusFalse)
                    }
                    
                case .failure(let err):
                    observer.onError(err)
                }
                observer.onCompleted()
            })
            return Disposables.create {
                dataRequest.cancel()
                debugPrint("request Disposables")
            }
        }
	}
    
    func downloadFile(url:String) -> Observable<Data> {
        return Observable<Data>.create { [weak self] (observer) -> Disposable in
            guard let weakSelf = self else { return Disposables.create() }
            var headersParams = [String: String]()
            if DTUser.sharedUser.isLogin {
                headersParams["token"] = DTUser.sharedUser.token
            }
            headersParams["deviceId"] = MFSIdentifier.deviceID()
            let headers = HTTPHeaders(headersParams)
            let downloadTask = weakSelf.session.download(downloadUrl + url, method: .get, headers: headers).responseData { (response) in
                switch response.result {
                case .success(let data):
                    observer.onNext(data)
                case .failure(let err):
                    observer.onError(err)
                }
                observer.onCompleted()
            }
            return Disposables.create {
                downloadTask.cancel()
            }
        }
    }
}

//定义一个结构体，存储认证相关信息
struct IdentityAndTrust {
	var identityRef:SecIdentity
	var trust:SecTrust
	var certArray:AnyObject
}
