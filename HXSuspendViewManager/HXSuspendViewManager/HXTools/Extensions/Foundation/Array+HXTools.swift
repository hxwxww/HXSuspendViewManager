//
//  Array+HXTools.swift
//  HXTools
//
//  Created by HongXiangWen on 2018/12/21.
//  Copyright © 2018年 WHX. All rights reserved.
//

import Foundation

// MARK: -  操作数组
extension Array {
    
    ///  替换元素
    ///
    /// - Parameters:
    ///   - index: 替换的下标
    ///   - element: 要替换的元素
    mutating func hx_replaceElement(at index: Int, with element: Element) {
        if index > count - 1 || index < 0 {
            return
        }
        replaceSubrange(index ..< index + 1, with: [element])
    }

    /// 随机获取一个元素
    ///
    /// - Returns: 取出的元素
    func hx_randomElement() -> Element? {
        return randomElement()
    }
    
    /// 随机获取多个元素
    ///
    /// - Parameters:
    ///   - size: 元素个数
    ///   - shouldRepeat: 取出的元素是否可以重复，默认不可以
    /// - Returns: 取出的元素数组
    func hx_randomElements(size: Int, shouldRepeat: Bool = false) -> [Element]? {
        guard count > 0 else { return nil }
        var randomElements: [Element] = []
        if shouldRepeat {
            // 元素可以重复的情况
            for _ in 0 ..< size {
                if let randomElement = hx_randomElement() {
                    randomElements.append(randomElement)
                }
            }
        } else {
            // 元素不可以重复的情况
            var copyElements = self
            for _ in 0 ..< size {
                // 如果copyElements的元素取光了
                if copyElements.isEmpty {
                    break
                }
                let randomIndex = Int(arc4random_uniform(UInt32(copyElements.count)))
                randomElements.append(copyElements[randomIndex])
                copyElements.remove(at: randomIndex)
            }
        }
        return randomElements
    }

}

// MARK: -  Equatable
extension Array where Element: Equatable {
    
    /// 删除元素
    ///
    /// - Parameter elements: 要删除的元素，为可变参数
    mutating func hx_remove(_ elements: Element...) {
        hx_remove(elements)
    }
    
    /// 删除元素
    ///
    /// - Parameter elements: 要删除的元素，为数组
    mutating func hx_remove(_ elements: [Element]) {
        for element in elements {
            if let index = index(of: element) {
                remove(at: index)
            }
        }
    }
    
}

// MARK: -  Codable
extension Array where Element: Codable {
    
    /// 转换为jsonString
    var hx_jsonString: String? {
        guard let data = try? JSONEncoder().encode(self),
            let jsonString = String(data: data, encoding: .utf8) else {
                return nil
        }
        return jsonString
    }
    
    /// 通过jsonString创建实例
    ///
    /// - Parameter jsonString: jsonString
    init?(jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8),
            let array = try? JSONDecoder().decode(Array.self, from: jsonData) else {
                return nil
        }
        self = array
    }
    
}
