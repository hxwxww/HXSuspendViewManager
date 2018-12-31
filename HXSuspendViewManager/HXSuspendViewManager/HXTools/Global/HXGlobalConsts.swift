//
//  HXGlobalConsts.swift
//  HXTools
//
//  Created by HongXiangWen on 2018/12/28.
//  Copyright © 2018年 WHX. All rights reserved.
//

import UIKit

/// AppDelegate
let hx_appDelegate = UIApplication.shared.delegate as! AppDelegate

/// 主window
let hx_keyWindow = UIApplication.shared.keyWindow

/// 判断是否为iPad
let hx_isIPad = UIDevice.current.userInterfaceIdiom == .pad

/// 判断是否为iPhone
let hx_isIPhone = UIDevice.current.userInterfaceIdiom == .phone

/// 获取屏幕bounds
let hx_screenBounds = UIScreen.main.bounds

/// 获取屏幕尺寸
let hx_screenSize = UIScreen.main.bounds.size

/// 获取屏幕宽度
let hx_screenWidth = UIScreen.main.bounds.width

/// 获取屏幕高度
let hx_screenHeight = UIScreen.main.bounds.height

/// 获取状态栏高度
let hx_statusBarHeight = UIApplication.shared.statusBarFrame.height

/// 判断是否是IPhoneX
let hx_isIPhoneX = hx_screenSize.equalTo(CGSize(width: 414, height: 896)) || hx_screenSize.equalTo(CGSize(width: 896, height: 414)) || hx_screenSize.equalTo(CGSize(width: 375, height: 812)) || hx_screenSize.equalTo(CGSize(width: 812, height: 375))

/// 获取导航栏高度
let hx_navigationBarHeight: CGFloat = 44.0

/// 获取工具栏高度
let hx_tabBarHeight: CGFloat = 49.0

/// 获取顶部安全高度
let hx_safeTopHeight = hx_statusBarHeight + hx_navigationBarHeight

/// 获取底部安全高度
let hx_safeBottomHeight: CGFloat = hx_isIPhoneX ? 34 : 0
