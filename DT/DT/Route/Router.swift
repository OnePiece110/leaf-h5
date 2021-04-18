//
//  Router.swift
//  Router
//
//  Created by 叶金永 on 2019/1/7.
//  Copyright © 2019 Keyon. All rights reserved.
//

import UIKit
import MobileCoreServices
import ZLPhotoBrowser
import Photos

public protocol Routable {
	/**
	类的初始化方法 - params 传参字典
	*/
	static func initWithParams(params: [String: Any]?) -> UIViewController
}


open class Router {
	
    // MARK: -- 相册选择器
    class func presentAlbumVC(target: UIViewController, maxSelectCount: Int, assets: [PHAsset], selectImageBlock: ( ([UIImage], [PHAsset], Bool) -> Void )?) {
        let config = ZLPhotoConfiguration.default()
        config.allowSelectImage = true
        config.allowSelectVideo = false
        config.allowSelectGif = false
        config.allowSelectLivePhoto = false
        config.allowSelectOriginal = true
        config.cropVideoAfterSelectThumbnail = true
        config.allowEditVideo = true
        config.allowMixSelect = false
        config.maxSelectCount = maxSelectCount
        config.maxEditVideoTime = 15
        config.languageType = .chineseSimplified
        
        // You can first determine whether the asset is allowed to be selected.
        config.canSelectAsset = { (asset) -> Bool in
            return true
        }
        
        config.noAuthorityCallback = { (type) in
            switch type {
            case .library:
                debugPrint("No library authority")
            case .camera:
                debugPrint("No camera authority")
            case .microphone:
                debugPrint("No microphone authority")
            }
        }
        
        let ac = ZLPhotoPreviewSheet(selectedAssets: assets)
        ac.selectImageBlock = selectImageBlock
        ac.cancelBlock = {
            debugPrint("cancel select")
        }
        ac.selectImageRequestErrorBlock = { (errorAssets, errorIndexs) in
            debugPrint("fetch error assets: \(errorAssets), error indexs: \(errorIndexs)")
        }
        
        ac.showPhotoLibrary(sender: target)
    }
    
	//MARK: -- 打开自带相机
	class func presentUIImagePickerController(isCamera:Bool) -> UIImagePickerController {
		let vc = UIImagePickerController()
		// *修改导航背景色
		vc.navigationBar.barTintColor = UIColor.dt.hex("#00D2FF")
		// *修改导航栏文字颜色
		vc.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 17)]
		vc.navigationBar.shadowImage = UIImage()
		// *修改导航栏按钮颜色
		vc.navigationBar.tintColor = UIColor.white
		vc.navigationBar.backgroundColor = .clear
		vc.navigationBar.isTranslucent = false
		vc.modalPresentationStyle = .overCurrentContext
		vc.allowsEditing = true
		if isCamera {
			vc.mediaTypes = [kUTTypeImage as String]
			vc.sourceType = .camera
		}
		let topViewController = DTConstants.currentTopViewController()
		topViewController?.present(vc, animated: true, completion: nil)
		return vc
	}
	
	// MARK: -- 弹窗
	class func presentAlertVc(confirmBtn:String?, message:String, title:String, cancelBtn:String?, handler:((UIAlertAction) ->Void)?) {
        
		let alertVc = UIAlertController(title: title, message: message, preferredStyle: .alert)
		if let cancelBtn = cancelBtn {
			let cancelAction = UIAlertAction(title: cancelBtn, style: .cancel, handler:nil)
			alertVc.addAction(cancelAction)
		}
		
		if let confirmBtn = confirmBtn {
			let okAction = UIAlertAction(title: confirmBtn, style: .default, handler: handler)
			alertVc.addAction(okAction)
		}
		let topViewController = DTConstants.currentTopViewController()
		topViewController?.present(alertVc, animated:true, completion:nil)
	}
	
	
	// MARK: -- 打电话
	open class func openTel(_ phone:String) {
		if let url = URL(string: "tel://\(phone)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
		}
	}
    
    // MARK: -- 打开连接
    open class func openLink(_ link:String) {
        if let url = URL(string: link) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
	
	private class func swiftClassFromString(className: String) -> AnyClass? {
		// get the project name
		if  let appName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String? {
			// YourProject.className
			let classStringName = appName + "." + className
			return NSClassFromString(classStringName)
		}
		return nil;
	}
	
	/*路由跳转 支持网络跳转和appe内跳转
	应用内跳转可以 比如:WenViewController(类名)?后面跟着参数 也可以自定义参数
	网页可以自定义 参数 也可以没有参数
    */
    @discardableResult
	class func routeTo(_ routeUrl:String, params:[String: Any]?, present: Bool = false) -> UIViewController? {
        var vc:UIViewController?
        if routeUrl.isVaildEmpty() {
            debugPrint("Error Url")
            return nil
        }
        let customParams = self.dealPath(routeUrl, params: params)
        vc = self.jumpTo(routeUrl, params: customParams, present: present)
        return vc
	}
    
    @discardableResult
    class func routeToClass(_ classPath:AnyClass, params:[String: Any]? = nil, isCheckLogin: Bool = false, present: Bool = false, animated: Bool = true , hidesBottomBarWhenPushed: Bool = true) -> UIViewController? {
        if isCheckLogin && !DTUser.sharedUser.isLogin {
            return Router.routeToClass(DTLoginViewController.self, params: ["isAddNavigation":true], present: true)
        }
        if let cls = classPath as? Routable.Type {
            let vc = cls.initWithParams(params: params)
            vc.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed
            let topViewController = DTConstants.currentTopViewController()
            if topViewController?.navigationController != nil && !present {
                topViewController?.navigationController?.pushViewController(vc, animated: animated)
            } else {
                topViewController?.present(vc, animated: animated , completion: nil)
                
            }
            return vc
        } else {
            assert(false, "此类型没有遵守Routable协议")
            return nil
        }
    }
    
	class private func dealPath(_ path:String, params:[String: Any]?) -> [String: Any]? {
		var customParams = [String: Any]()
		if let _ = path.range(of: "?") {
			if let params = params {
				customParams.merge(params) { (param, _) in param }
			}
			if let pathParams = path.urlParameters {
				customParams.merge(pathParams) { (param, _) in param }
			}
			return customParams
		}
		if path.contains("http") {
			return customParams
		} else {
			return params
		}
		
	}
	
	///路由处理
	private class func jumpTo(_ path:String, params:[String: Any]?, present: Bool = false , animated: Bool = true , hidesBottomBarWhenPushed: Bool = true) -> UIViewController? {
		if let classPath = self.swiftClassFromString(className: path) {
			if let cls = classPath as? Routable.Type {
				let vc = cls.initWithParams(params: params)
				vc.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed
				let topViewController = DTConstants.currentTopViewController()
				if topViewController?.navigationController != nil && !present {
					topViewController?.navigationController?.pushViewController(vc, animated: animated)
				} else {
					topViewController?.present(vc, animated: animated , completion: nil)
					
				}
                return vc
			} else {
				assert(false, "此类型没有遵守Routable协议")
                return nil
			}
		} else {
			assert(false, "此类型名不存在")
            return nil
		}
	}
}
