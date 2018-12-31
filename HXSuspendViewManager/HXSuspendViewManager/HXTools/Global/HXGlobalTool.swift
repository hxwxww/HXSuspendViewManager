//
//  HXGlobalTool.swift
//  HXTools
//
//  Created by HongXiangWen on 2018/12/26.
//  Copyright © 2018年 WHX. All rights reserved.
//

import UIKit

struct HXGlobalTool {
    
    /// 获取缓存文件路径
    ///
    /// - Returns: 结果
    static func cachesDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last!
    }
    
    /// 获取持久文件路径
    ///
    /// - Returns: 结果
    func documentDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
    }
    
    /// 获取临时文件路径
    ///
    /// - Returns: 结果
    func tmpDirectory() -> String {
        return NSTemporaryDirectory()
    }

}
