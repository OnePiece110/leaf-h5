//
//  DTWebViewController.swift
//  DT
//
//  Created by Ye Keyon on 2020/12/15.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

class DTWebViewController: DTBaseViewController,WKUIDelegate,Routable {

    private var webView:WKWebView!
    
    private var navTitle:String?
    private var urlStr:String?
    private var htmlText:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = navTitle
        self.setupWebView()
    }
    
    static func initWithParams(params: [String: Any]?) -> UIViewController {
        let vc = DTWebViewController()
        if let params = params {
            vc.urlStr = params[DTWKURL] as? String
            if let navTitle = params[DTWKTitle] as? String {
                vc.navTitle = navTitle
            }
        }
        return vc
    }
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.selectionGranularity = WKSelectionGranularity.character
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        let userContentController = WKUserContentController()
        configuration.preferences = preferences
        configuration.userContentController = userContentController
        webView = WKWebView(frame: self.view.bounds, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.backgroundColor = .clear
        webView.isOpaque = false
        self.view.addSubview(webView)
        
        webView.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(0)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(0)
            }
        }
        
        loadCookies(userContent: userContentController)
        if let urlStr = urlStr {
            let newStr = urlStr.trimmingCharacters(in: .whitespaces)
            var request:URLRequest!
            if let url = URL(string: newStr) {
                if !UIApplication.shared.canOpenURL(url) {
                    let _urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    let secondUrl = URL(string: _urlStr!)
                    request = URLRequest(url: secondUrl!)
                } else {
                    request = URLRequest(url: url)
                }
            }
            DTProgress.showProgress(in: self)
            webView.load(request)
        }
        
        if let htmlText = htmlText {
            webView.loadHTMLString(htmlText, baseURL: nil)
        }
        
    }
    
    //登录之后就会返回的cookies
    func loadCookies(userContent:WKUserContentController) {
        guard let cookieArray = UserDefaults.standard.array(forKey: "savedCookies") as? [[HTTPCookiePropertyKey: Any]] else { return }
        for cookieProperties in cookieArray {
            if let cookie = HTTPCookie(properties: cookieProperties) {
                if #available(iOS 11.0, *) {
                    let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
                    cookieStore.setCookie(cookie)
                } else {
                    setWebCookie(userContent: userContent)
                }
            }
        }
    }
    
    func setWebCookie(userContent:WKUserContentController) {
        var cookieString = ""
        if let cookieArray = UserDefaults.standard.array(forKey: "savedCookies") {
            for cookieData in cookieArray {
                if let dict = cookieData as? [HTTPCookiePropertyKey : Any] {
                    if let cookie = HTTPCookie.init(properties : dict) {
                        cookieString.append("document.cookie =" + "'" + cookie.name + "=" + cookie.value + "';")
                    }
                }
            }
        }
        
        let  cookieScript = WKUserScript(source: cookieString, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: false)
        userContent.addUserScript(cookieScript)
    }
    
    //MARK: -- back是我们和前端商量好的方法名 注册之后一定要注意removeScriptMessageHandlerForName
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let userContentController = webView.configuration.userContentController
        userContentController.add(self, name: "back")
        userContentController.add(self, name: "openShare")
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            if let object = object as? WKWebView {
                if object == self.webView {
                    if let navTitle = self.navTitle {
                        self.title = navTitle
                    } else {
                        self.title = self.webView.title
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let userContentController = webView.configuration.userContentController
        userContentController.removeScriptMessageHandler(forName: "back")
        userContentController.removeScriptMessageHandler(forName: "openShare")
        webView.removeObserver(self, forKeyPath: "title", context: nil)
    }
    
    deinit {
        clear()
    }
    
    private func clear() {
        let websiteDataTypes = WKWebsiteDataStore.allWebsiteDataTypes()
        let dateFrom = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes, modifiedSince: dateFrom) {
        }
    }
    
}

extension DTWebViewController:WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DTProgress.dismiss(in: self)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url?.absoluteString
        if let url = url {
            debugPrint(url)
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let space = challenge.protectionSpace
        if let serverTrust = space.serverTrust {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential,credential)
        } else {
            completionHandler(.useCredential,nil)
        }
    }
    
    // 监听通过JS调用警告框
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // 监听通过JS调用提示框
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // 监听JS调用输入框
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        // 类似上面两个方法
    }
    
}

extension DTWebViewController:WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugPrint(message.name, message.body)
    }
}
