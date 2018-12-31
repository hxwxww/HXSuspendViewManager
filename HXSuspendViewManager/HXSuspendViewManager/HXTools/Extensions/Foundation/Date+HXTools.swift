//
//  Date+HXTools.swift
//  HXTools
//
//  Created by HongXiangWen on 2018/12/22.
//  Copyright © 2018年 WHX. All rights reserved.
//

import Foundation

// MARK: -  日期简单处理
extension Date {
    
    /// 时间戳
    var hx_timestamp: TimeInterval {
        return timeIntervalSince1970
    }
    
    /// 通过时间戳创建实例
    ///
    /// - Parameter timestamp: 时间戳
    init(timestamp: TimeInterval) {
        self.init(timeIntervalSince1970: timestamp)
    }
    
    /// 年
    var hx_year: Int {
        return NSCalendar.current.component(.year, from: self)
    }
    
    /// 月
    var hx_month: Int {
        return NSCalendar.current.component(.month, from: self)
    }
    
    /// 日
    var hx_day: Int {
        return NSCalendar.current.component(.day, from: self)
    }
    
    /// 时
    var hx_hour: Int {
        return NSCalendar.current.component(.hour, from: self)
    }
    
    /// 分
    var hx_minute: Int {
        return NSCalendar.current.component(.minute, from: self)
    }
    
    /// 秒
    var hx_second: Int {
        return NSCalendar.current.component(.second, from: self)
    }
    
    /// 星期几，数字(1~7)
    var hx_weekday: Int {
        return NSCalendar.current.component(.weekday, from: self)
    }
    
    /// 星期几，中文名称（星期一、星期二...星期日）
    var hx_weekdayName: String {
        guard let weekdayName = Weekday(rawValue: hx_weekday)?.description else {
            fatalError("Error: weekday:\(hx_weekday)")
        }
        return weekdayName
    }
    
    /// 是否是今天
    var hx_isToday: Bool {
        return NSCalendar.current.isDateInToday(self)
    }
    
    /// 是否是昨天
    var hx_isYesterday: Bool {
        return NSCalendar.current.isDateInYesterday(self)
    }
    
}

// MARK: -  格式化
extension Date {
    
    /// 时间格式化成字符串
    ///
    /// - Parameter dateFormat: 格式
    /// - Returns: 时间字符串
    func hx_string(with dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: self)
    }
    
    /// 通过字符串创建实例
    ///
    /// - Parameters:
    ///   - string: 字符串
    ///   - dateFormat: 格式
    init?(string: String, dateFormat: String = "yyyy-MM-dd HH:mm:ss") {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        guard let date = formatter.date(from: string) else { return nil }
        self = date
    }
    
    /// 类似微信聊天消息的时间格式化，静态方法
    ///
    /// - Parameters:
    ///   - timestamp: 时间戳
    ///   - showHour: 是否显示时分
    /// - Returns: 格式化后的字符串
    static func hx_stringWithFormat(timestamp: TimeInterval, showHour: Bool = true) -> String {
        let date = Date(timestamp: timestamp)
        return date.hx_stringWithFormat(showHour: showHour)
    }
    
    /// 类似微信聊天消息的时间格式化，实例
    ///
    /// - Parameter showHour: 是否显示时分
    /// - Returns: 格式化后的字符串
    func hx_stringWithFormat(showHour: Bool = true) -> String {
        let dateFormatter = DateFormatter()
        if hx_isToday {
            /// 如果是今天
            dateFormatter.dateFormat = "HH:mm"
        } else if hx_isYesterday {
            /// 如果是昨天
            dateFormatter.dateFormat = showHour ? "昨天 HH:mm" : "昨天"
        } else if hx_numberOfdays(to: Date()) < 7 {
            /// 如果在一周内
            dateFormatter.dateFormat = showHour ? "\(hx_weekdayName) HH:mm" : "\(hx_weekdayName)"
        } else {
            /// 如果是今年
            if hx_year == Date().hx_year {
                dateFormatter.dateFormat = showHour ? "MM月dd日 HH:mm" : "MM月dd日"
            } else {
                dateFormatter.dateFormat = showHour ? "yyyy年MM月dd日 HH:mm" : "yyyy年MM月dd日"
            }
        }
        return dateFormatter.string(from: self)
    }
    
    
    /// 获取两个日期之间相隔的天数，self为起始日期，date为截止日期
    ///
    /// - Parameter date: 截止日期
    /// - Returns: 相隔天数
    func hx_numberOfdays(to date: Date) -> Int {
        let components = Calendar.current.dateComponents([.day], from: self, to: date)
        return components.day ?? 0
    }
    
}

// MARK: -  Weekday简单封装
enum Weekday: Int {
    
    case sunday    = 1
    case monday    = 2
    case tuesday   = 3
    case wednesday = 4
    case thursday  = 5
    case friday    = 6
    case saturday  = 7
    
    init?(weekdayString: String) {
        switch weekdayString {
        case Weekday.sunday.description:     self = .sunday
        case Weekday.monday.description:     self = .monday
        case Weekday.tuesday.description:    self = .tuesday
        case Weekday.wednesday.description:  self = .wednesday
        case Weekday.thursday.description:   self = .thursday
        case Weekday.friday.description:     self = .friday
        case Weekday.saturday.description:   self = .saturday
        default: return nil
        }
    }
    
    var description: String {
        switch self {
        case .sunday:     return "星期日"
        case .monday:     return "星期一"
        case .tuesday:    return "星期二"
        case .wednesday:  return "星期三"
        case .thursday:   return "星期四"
        case .friday:     return "星期五"
        case .saturday:   return "星期六"
        }
    }
    
}
