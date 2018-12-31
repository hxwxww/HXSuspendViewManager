//
//  VipcnViewController.swift
//  HXSuspendViewManager
//
//  Created by HongXiangWen on 2018/12/30.
//  Copyright © 2018年 WHX. All rights reserved.
//

import UIKit

class VipcnViewController: UIViewController, HXSuspendViewController {
    
    // MARK: -  HXSuspendViewController
    var suspendIdentifier: Int {
        return hashValue
    }
    
    var suspendIcon: UIImage? {
        return UIImage(named: "2")
    }

    // MARK: -  life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.hx_randomColor()
    }
    
}
