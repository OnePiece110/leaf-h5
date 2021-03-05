//
//  DTSearchViewController.swift
//  DT
//
//  Created by Ye Keyon on 2020/6/30.
//  Copyright © 2020 dt. All rights reserved.
//

import UIKit

class DTSearchViewController: DTBaseViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() -> Void {
        self.navigationItem.title = "发现"
        self.tabBarItem.title = "发现"
    }

}
