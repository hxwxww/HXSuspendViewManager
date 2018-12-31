//
//  HXSuspendViewController.swift
//  HXSuspendViewManager
//
//  Created by HongXiangWen on 2018/12/30.
//  Copyright © 2018年 WHX. All rights reserved.
//

import UIKit

protocol HXSuspendViewController  {
    
    /// 悬浮窗icon图片
    var suspendIcon: UIImage? { get }
    /// id
    var suspendIdentifier: Int { get }

}
