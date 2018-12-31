//
//  HXAlertTool.swift
//  HXTools
//
//  Created by HongXiangWen on 2018/12/26.
//  Copyright © 2018年 WHX. All rights reserved.
//

import UIKit

/// 点击回调
typealias HXAlertHandler = (HXAlertHandleType) -> ()

/// 点击的按钮类型
///
/// - `default`: 默认的按钮
/// - cancel: 取消
/// - destructive: 警告
enum HXAlertHandleType {
    case `default`(index: Int)
    case cancel
    case destructive
}

// MARK: - UIAlertController简单封装
struct HXAlertTool {
    
    /// 弹出提示框
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 信息
    ///   - preferredStyle: 样式，默认为alert
    ///   - cancelTitle: 取消按钮标题
    ///   - destructiveTitle: 警告按钮标题，默认为nil
    ///   - defaultTitles: 正常按钮标题，可输入多个
    ///   - handler: 回调
    static func showAlert(title: String?, message: String?, preferredStyle: UIAlertController.Style = .alert, cancelTitle: String?, destructiveTitle: String? = nil, defaultTitles: [String]?, handler: HXAlertHandler?) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        if let cancelTitle = cancelTitle {
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { (_) in
                handler?(.cancel)
            }
            alertVC.addAction(cancelAction)
        }
        if let destructiveTitle = destructiveTitle {
            let destructiveAction = UIAlertAction(title: destructiveTitle, style: .destructive) { (_) in
                handler?(.destructive)
            }
            alertVC.addAction(destructiveAction)
        }
        if let defaultTitles = defaultTitles {
            for i in 0 ..< defaultTitles.count {
                let defaultTitle = defaultTitles[i]
                let defaultAction = UIAlertAction(title: defaultTitle, style: .default) { (_) in
                    handler?(.default(index: i))
                }
                alertVC.addAction(defaultAction)
            }
        }
        hx_topViewController()?.present(alertVC, animated: true, completion: nil)
    }
    
    /// 弹出简易提示框，只有一个按钮
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 信息
    ///   - preferredStyle: 样式，默认为alert
    ///   - cancelTitle: 按钮标题
    ///   - handler: 回调，默认为nil
    static func showSimpleAlert(title: String?, message: String?, preferredStyle: UIAlertController.Style = .alert, cancelTitle: String?, handler: HXAlertHandler? = nil) {
        showAlert(title: title, message: message, preferredStyle: preferredStyle, cancelTitle: cancelTitle, destructiveTitle: nil, defaultTitles: nil, handler: nil)
    }
    
}
