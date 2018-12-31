//
//  String+HXTools.swift
//  HXTools
//
//  Created by HongXiangWen on 2018/12/24.
//  Copyright © 2018年 WHX. All rights reserved.
//

import Foundation
import UIKit

// MARK: -  操作字符串
extension String {
    
    /// 插入字符串
    ///
    /// - Parameters:
    ///   - text: 要插入的字符串
    ///   - index: 要插入的位置
    /// - Returns: 结果字符串
    @discardableResult
    mutating func hx_insert(_ text: String, at index: Int) -> String {
        if index > count - 1 || index < 0 {
            return self
        }
        let insertIndex = self.index(startIndex, offsetBy: index)
        insert(contentsOf: text, at: insertIndex)
        return self
    }
    
    /// 插入字符
    ///
    /// - Parameters:
    ///   - text: 要插入的字符
    ///   - index: 要插入的位置
    /// - Returns: 结果字符串
    @discardableResult
    mutating func hx_insert(_ text: Character, at index: Int) -> String {
        if index > count - 1 || index < 0 {
            return self
        }
        let insertIndex = self.index(startIndex, offsetBy: index)
        insert(text, at: insertIndex)
        return self
    }
    
    /// 删除字符串
    ///
    /// - Parameter text: 要删除的字符串
    /// - Returns: 结果字符串
    @discardableResult
    mutating func hx_remove(_ text: String) -> String {
        if let removeIndex = range(of: text) {
            removeSubrange(removeIndex)
        }
        return self
    }
    
    /// 删除字符串
    ///
    /// - Parameters:
    ///   - index: 删除的字符串起始位置
    ///   - length: 删除的字符串长度
    /// - Returns: 结果字符串
    @discardableResult
    mutating func hx_remove(at index: Int, length: Int) -> String {
        if index > count - 1 || index < 0 || length < 0 || index + length > count {
            return self
        }
        let start = self.index(startIndex, offsetBy: index)
        let end = self.index(start, offsetBy: length)
        removeSubrange(start ..< end)
        return self
    }
    
    /// 删除字符
    ///
    /// - Parameter index: 要删除的位置
    /// - Returns: 结果字符串
    @discardableResult
    mutating func hx_remove(at index: Int) -> String {
        if index > count - 1 || index < 0 {
            return self
        }
        let removeIndex = self.index(startIndex, offsetBy: index)
        remove(at: removeIndex)
        return self
    }
    
    /// 替换字符串
    ///
    /// - Parameters:
    ///   - index: 替换的字符串起始位置
    ///   - length: 替换的字符串长度
    ///   - text: 要替换成的字符串
    /// - Returns: 结果字符串
    @discardableResult
    mutating func hx_replaceText(at index: Int, length: Int, with text: String) -> String {
        if index > count - 1 || index < 0 || length < 0 || index + length > count {
            return self
        }
        let start = self.index(startIndex, offsetBy: index)
        let end = self.index(start, offsetBy: length)
        replaceSubrange(start ..< end, with: text)
        return self
    }
    
    /// 截取字符串
    ///
    /// - Parameters:
    ///   - index: 截取的字符串起始位置
    ///   - length: 截取的字符串长度
    /// - Returns: 截取的字符串
    func hx_substring(at index: Int, length: Int) -> String {
        if index > count - 1 || index < 0 || length < 0 || index + length > count {
            return self
        }
        let fromIndex = self.index(startIndex, offsetBy: index)
        let toIndex = self.index(fromIndex, offsetBy: length)
        return String(self[fromIndex ..< toIndex])
    }
    
    /// 截取字符串，从指定位置到末尾
    ///
    /// - Parameter index: 截取的字符串起始位置
    /// - Returns: 截取的字符串
    func hx_substring(from index: Int) -> String {
        if index > count - 1 || index < 0 {
            return self
        }
        return hx_substring(at: index, length: count - index)
    }
    
    /// 截取字符串，从开头到指定位置
    ///
    /// - Parameter index: 截取的字符串结束位置
    /// - Returns: 截取的字符串
    func hx_substring(to index: Int) -> String {
        if index > count - 1 || index < 0 {
            return self
        }
        return hx_substring(at: 0, length: index)
    }
    
    /// 去除左右的空格和换行符
    ///
    /// - Returns: 结果字符串
    func trim() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}

// MARK: -  编解码
extension String {
    
    /// 编码之后的url
    var hx_urlEncoded: String? {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    /// 解码之后的url
    var hx_urlDecoded: String? {
        return removingPercentEncoding
    }
    
    /// base64编码之后的字符串
    var hx_base64Encoded: String? {
        guard let base64Data = data(using: .utf8) else { return nil }
        return base64Data.base64EncodedString()
    }
    
    /// base64解码之后的字符串
    var hx_base64Decoded: String? {
        guard let base64Data = Data(base64Encoded: self) else { return nil }
        return String(data: base64Data, encoding: .utf8)
    }
    
}

// MARK: -  验证
extension String {
    
    /// 是否是数字
    var hx_isNumber: Bool {
        let regex = "^[0-9]+$"
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        return pred.evaluate(with: self)
    }
    
    /// 是否是字母
    var hx_isLetter: Bool {
        let regex = "^[A-Za-z]+$"
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        return pred.evaluate(with: self)
    }
    
    /// 是否是手机号
    var hx_isPhoneNumber: Bool {
        let regex = "^1+[3456789]+\\d{9}$"
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        return pred.evaluate(with: self)
    }
    
    /// 是否是身份证号
    var hx_isIDNumber: Bool {
        let regex = "^(\\d{14}|\\d{17})(\\d|[xX])$"
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        return pred.evaluate(with: self)
    }
    
    /// 是否是6位数字
    var hx_isSixNumber: Bool {
        let regex = "^\\d{6}$"
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        return pred.evaluate(with: self)
    }
    
    /// 是否是邮箱
    var hx_isEmail: Bool {
        let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$"
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        return pred.evaluate(with: self)
    }
    
    /// 是否是密码，6-20位
    var hx_isPassword: Bool {
        let regex = "^[@A-Za-z0-9!#\\$%\\^&*\\.~_]{6,20}$"
        let pred = NSPredicate(format: "SELF MATCHES %@", regex)
        return pred.evaluate(with: self)
    }
    
}

// MARK: -  尺寸计算
extension String {
    
    /// 计算字符串尺寸
    ///
    /// - Parameters:
    ///   - size: 限定的size
    ///   - font: 字体
    /// - Returns: 计算出的尺寸
    func hx_size(with size: CGSize, font: UIFont) -> CGSize {
        if isEmpty {
            return .zero
        }
        let attributes = [NSAttributedString.Key.font: font]
        return (self as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
    }
    
    /// 计算字符串的高度
    ///
    /// - Parameters:
    ///   - width: 限定的宽度
    ///   - font: 字体
    /// - Returns: 计算出的高度
    func hx_height(with width: CGFloat, font: UIFont) -> CGFloat {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        return hx_size(with: size, font: font).height
    }
    
    /// 计算字符串的宽度
    ///
    /// - Parameter font: 字体
    /// - Returns: 计算出的宽度
    func hx_width(with font: UIFont) -> CGFloat {
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: 0)
        return hx_size(with: size, font: font).width
    }
    
}
