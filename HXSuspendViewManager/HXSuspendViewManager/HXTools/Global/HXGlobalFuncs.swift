//
//  HXGlobalFuncs.swift
//  HXTools
//
//  Created by HongXiangWen on 2018/12/26.
//  Copyright © 2018年 WHX. All rights reserved.
//

import UIKit

/// 自定义log
///
/// - Parameters:
///   - message: 打印信息
///   - filePath: 文件路径
///   - methodName: 方法名
///   - line: 行数
func HXLog<T>(_ message: T, filePath: String = #file, methodName: String = #function, line: Int = #line) {
    #if DEBUG
    let fileName = (filePath as NSString).lastPathComponent.components(separatedBy: ".").first!
    print("==>> \(fileName).\(methodName)[\(line)]: \(message) \n")
    #endif
}

/// 获取当前最上层VC
///
/// - Parameter rootVC: 底部VC
/// - Returns: 结果
func hx_topViewController(_ rootVC: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    if let tabbarVC = rootVC as? UITabBarController, let selectedVC = tabbarVC.selectedViewController  {
        return hx_topViewController(selectedVC)
    } else if let naviVC = rootVC as? UINavigationController, let visibleVC = naviVC.visibleViewController {
        return hx_topViewController(visibleVC)
    } else if let presentedVC = rootVC?.presentedViewController {
        return hx_topViewController(presentedVC)
    }
    return rootVC
}

///  打印类的所有实例变量
///
/// - Parameter aClass: 目标类
func hx_printIvars(_ aClass: AnyClass) {
    HXLog("开始打印 =======")
    var count: UInt32 = 0
    let ivars = class_copyIvarList(aClass, &count)
    for i in 0 ..< count {
        let ivar = ivars![Int(i)]
        HXLog(String(utf8String: ivar_getName(ivar)!) ?? "")
    }
    free(ivars)
    HXLog("结束打印 =======")
}

///  打印类的所有属性变量
///
/// - Parameter aClass: 目标类
func hx_printProperties(_ aClass: AnyClass) {
    HXLog("开始打印 =======")
    var count: UInt32 = 0
    let properties = class_copyPropertyList(aClass, &count)
    for i in 0 ..< count {
        let property = properties![Int(i)]
        HXLog(String(utf8String: property_getName(property)) ?? "")
    }
    free(properties)
    HXLog("结束打印 =======")
}

/// 打印类的所有方法
///
/// - Parameter aClass: 目标类
func hx_printMethods(_ aClass: AnyClass) {
    HXLog("开始打印 =======")
    var count: UInt32 = 0
    let methods = class_copyMethodList(aClass, &count)
    for i in 0 ..< count {
        let method = methods![Int(i)]
        HXLog(method_getName(method))
    }
    free(methods)
    HXLog("结束打印 =======")
}
