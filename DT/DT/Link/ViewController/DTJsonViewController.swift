//
//  DTJsonViewController.swift
//  DT
//
//  Created by Ye Keyon on 2020/12/31.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

class DTJsonViewController: DTBaseViewController, Routable, UIActivityItemSource {

    var textView:UITextView!
    static func initWithParams(params: [String : Any]?) -> UIViewController {
        let vc = DTJsonViewController()
        if let params = params {
            let path = params["path"]
            if let path = path as? String {
                vc.path = path
            }
        }
        return vc
    }
    private var path:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = path
        configureSubViews()
        configureData()
        let refreshBtn = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(onRefresh))
        let shareBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: self, action: #selector(onShare))
        navigationItem.rightBarButtonItems = [shareBtn, refreshBtn]
    }
    

    func configureSubViews() {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 12)
        textView.backgroundColor = UIColor.black
        textView.textColor = UIColor.white
        self.view.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalTo(0)
            }
        }
        self.textView = textView
    }
    
    func configureData() {
        let domianConetont = try? String(contentsOf: logURL, encoding: .utf8)
        textView.text = domianConetont
        textView.isEditable = false
    }
    
    @objc func onRefresh() {
        let domianConetont = try? String(contentsOf: logURL, encoding: .utf8)
        textView.text = domianConetont
    }
    
    @objc func onShare() {
        let items = [self]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    var logURL:URL {
        return URL(fileURLWithPath: path ?? "")
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return logURL
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        return activityViewControllerPlaceholderItem(activityViewController)
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "KungFu.log"
    }

}
