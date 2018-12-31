//
//  Dictionary+HXTools.swift
//  HXTools
//
//  Created by HongXiangWen on 2018/12/22.
//  Copyright © 2018年 WHX. All rights reserved.
//

import Foundation

// MARK: -  操作字典
extension Dictionary {
    
    /// 添加字典
    ///
    /// - Parameter newDictionary: 要添加的字典
    mutating func hx_append(_ newDictionary: Dictionary) {
        for (key, value) in newDictionary {
            self[key] = value
        }
    }
    
    /// 判断是否存在key
    ///
    /// - Parameter key: 要判断的key
    /// - Returns: 判断结果
    func hx_hasKey(_ key: Key) -> Bool {
        return index(forKey: key) != nil
    }
    
    /// 删除元素
    ///
    /// - Parameter keys: 要删除的元素的key，为可变参数
    mutating func hx_remove(_ keys: Key...) {
        hx_remove(keys)
    }
    
    /// 删除元素
    ///
    /// - Parameter keys: 要删除的元素的key，为数组
    mutating func hx_remove(_ keys: [Key]) {
        for key in keys {
            removeValue(forKey: key)
        }
    }
    
}

// MARK: -  Codable
extension Dictionary where Key: Codable, Value: Codable {
    
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
            let dictionary = try? JSONDecoder().decode(Dictionary.self, from: jsonData) else {
                return nil
        }
        self = dictionary
    }
    
}
