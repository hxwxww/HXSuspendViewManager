//
//  UIColor+HXTools.swift
//  HXTools
//
//  Created by HongXiangWen on 2018/12/21.
//  Copyright © 2018年 WHX. All rights reserved.
//

import UIKit

/// rgba元组， r，g，b为0 ~ 255的值
typealias HXRGBAValue = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)

// MARK: -  UIColor通用封装
extension UIColor {
    
    /// r，g，b，a的值
    var hx_rgbaValue: HXRGBAValue {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red * 255, green * 255, blue * 255, alpha)
    }
    
    /// 是否是深色
    var hx_isDark: Bool {
        if(hx_rgbaValue.red * 0.299 + hx_rgbaValue.green * 0.587 + hx_rgbaValue.blue * 0.114 >= 192) {
            // 浅色
            return false
        } else {
            // 深色
            return true
        }
    }
    
    /// 16进制字符串
    var hx_hexString: String {
        let rgb :Int = Int(hx_rgbaValue.red) << 16 | Int(hx_rgbaValue.green) << 8 | Int(hx_rgbaValue.blue)
        return String(format: "%06X", rgb)
    }
    
    /// 反色
    var hx_invertColor: UIColor {
        return UIColor(r: 255 - hx_rgbaValue.red, g: 255 - hx_rgbaValue.green, b: 255 - hx_rgbaValue.blue)
    }
    
    /// 根据r、g、b、a生成颜色
    ///
    /// - Parameters:
    ///   - r: 红
    ///   - g: 绿
    ///   - b: 蓝
    ///   - a: 透明度
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    
    /// 根据16进制数hexValue生成颜色
    ///
    /// - Parameter hexValue: 16进制数
    convenience init(_ hexValue: UInt64, alpha: CGFloat = 1.0) {
        let r = CGFloat((hexValue & 0xFF0000) >> 16)
        let g = CGFloat((hexValue & 0xFF00) >> 8)
        let b = CGFloat(hexValue & 0xFF)
        self.init(r: r, g: g, b: b, a: alpha)
    }
    
    /// 根据16进制字符串hexString生成颜色
    ///
    /// - Parameter hexString: 16进制字符串
    convenience init(_ hexString: String, alpha: CGFloat = 1.0) {
        let scanner = Scanner(string: hexString)
        scanner.scanLocation = 0
        var hexValue: UInt64 = 0
        scanner.scanHexInt64(&hexValue)
        self.init(hexValue, alpha: alpha)
    }
    
    /// 随机颜色
    ///
    /// - Returns: 颜色实例
    class func hx_randomColor() -> UIColor {
        return hx_randomColor(fromValue: 0, toValue: 255)
    }
    
    /// 指定范围的随机颜色
    ///
    /// - Parameters:
    ///   - fromValue: 起始值
    ///   - toValue: 结束值
    /// - Returns: 颜色实例
    class func hx_randomColor(fromValue: CGFloat, toValue: CGFloat) -> UIColor {
        let from = max(min(fromValue, toValue), 0)
        let to = min(max(fromValue, toValue), 255)
        let delta = to - from
        if delta == 0 {
            return UIColor(r: fromValue, g: fromValue, b: fromValue)
        }
        let r: CGFloat = CGFloat(arc4random() % UInt32(delta)) + from
        let g: CGFloat = CGFloat(arc4random() % UInt32(delta)) + from
        let b: CGFloat = CGFloat(arc4random() % UInt32(delta)) + from
        return UIColor(r: r, g: g, b: b)
    }
    
    /// 通过两个颜色的中间比例值，获取中间颜色
    ///
    /// - Parameters:
    ///   - fromColor: 起始颜色
    ///   - toColor: 结束颜色
    ///   - percent: 中间值
    /// - Returns: 新的颜色实例
    class func hx_averageColor(fromColor: UIColor, toColor: UIColor, percent: CGFloat) -> UIColor {
        let fromRgbaValue = fromColor.hx_rgbaValue
        let toRgbaValue = toColor.hx_rgbaValue
        let red = fromRgbaValue.red + (toRgbaValue.red - fromRgbaValue.red) * percent
        let green = fromRgbaValue.green + (toRgbaValue.green - fromRgbaValue.green) * percent
        let blue = fromRgbaValue.blue + (toRgbaValue.blue - fromRgbaValue.blue) * percent
        let alpha = fromRgbaValue.alpha + (toRgbaValue.alpha - fromRgbaValue.alpha) * percent
        return UIColor(r: red, g: green, b: blue, a: alpha)
    }
    
}

