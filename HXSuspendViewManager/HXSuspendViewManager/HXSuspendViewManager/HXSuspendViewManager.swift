//
//  HXSuspendViewManager.swift
//  HXSuspendViewManager
//
//  Created by HongXiangWen on 2018/12/30.
//  Copyright © 2018年 WHX. All rights reserved.
//

import UIKit

// MARK: -  基本配置
struct HXSuspendViewConfig {
    
    /// 悬浮窗大小
    static let suspendViewSize = CGSize(width: 60, height: 60)
    /// 悬浮窗默认位置
    static let suspendViewRect = CGRect(x: hx_screenWidth - suspendViewSize.width - 10, y: 120, width: suspendViewSize.width, height: suspendViewSize.height)
    /// 悬浮窗边框颜色
    static let suspendBorderColor = UIColor.cyan
    /// 扇形view大小
    static let sectorViewSize = CGSize(width: 150, height: 150)
    /// 动画时间
    static let animateDuration: TimeInterval = 0.3
    
}

// MARK: -  悬浮窗的管理类，单例
class HXSuspendViewManager: NSObject {
    
    // 悬浮窗
    var suspendWindow: HXSuspendWindow?
    
    // 右下角扇形view
    lazy var circularSectorView: HXCircularSectorView = {
        let circularSectorView = HXCircularSectorView(frame: CGRect(x: hx_screenWidth, y: hx_screenHeight, width: HXSuspendViewConfig.sectorViewSize.width, height: HXSuspendViewConfig.sectorViewSize.height), type: .add)
        return circularSectorView
    }()
    
    // 用于动画的imageView
    var fakerImageView: UIImageView?
    
    // MARK: - 初始化单例
    static let shared = HXSuspendViewManager()
    private override init() {
        super.init()
    }
    
}

// MARK: -  Public Methods
extension HXSuspendViewManager {
    
    func addSuspendView(viewController: HXSuspendViewController, percent: CGFloat) {
        if suspendWindow == nil {
            suspendWindow = HXSuspendWindow(frame: HXSuspendViewConfig.suspendViewRect)
            suspendWindow?.delegate = self
        }
        suspendWindow?.viewContoller = viewController
        let currentKeyWindow = UIApplication.shared.keyWindow
        suspendWindow?.makeKeyAndVisible()
        currentKeyWindow?.makeKeyAndVisible()
        /// 假的转场动画
        fakeTransitionAnimation(percent)
    }
    
    func removeSuspendView() {
        suspendWindow?.removeFromSuperview()
        suspendWindow = nil
    }
    
    func changeSuspendViewAlpha(_ alpha: CGFloat, animated: Bool) {
        if animated {
            UIView.animate(withDuration: HXSuspendViewConfig.animateDuration) {
                self.suspendWindow?.alpha = alpha
            }
        } else {
            suspendWindow?.alpha = alpha
        }
    }
    
    func fakeTransitionAnimation(_ percent: CGFloat) {
        guard let suspendWindow = suspendWindow,
            let viewController = suspendWindow.viewContoller as? UIViewController,
            let keyWindow = UIApplication.shared.keyWindow else { return }
        /// 添加一个假的用于动画的imageView
        let fakerImageView = UIImageView()
        fakerImageView.frame = CGRect(x: percent * hx_screenWidth, y: 0, width: hx_screenWidth, height: hx_screenHeight)
        fakerImageView.image = viewController.view.hx_snapshotImage()
        keyWindow.addSubview(fakerImageView)
        /// 计算动画的path
        let originFrame = suspendWindow.frame
        let finalPath = UIBezierPath(ovalIn: CGRect(x: max(originFrame.minX - fakerImageView.frame.minX, 0), y: originFrame.minY, width: originFrame.size.width, height: originFrame.size.height))
        let beginRadius = HXCircleTransition.radius(with: originFrame.origin)
        let beginPath = UIBezierPath(ovalIn: originFrame.insetBy(dx: -beginRadius, dy: -beginRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = beginPath.cgPath
        fakerImageView.layer.mask = maskLayer
        /// 改变fakerImageView位置动画
        UIView.animate(withDuration: HXSuspendViewConfig.animateDuration) {
            fakerImageView.frame = CGRect(x: min(originFrame.minX, percent * hx_screenWidth), y: 0, width: fakerImageView.frame.width, height: fakerImageView.frame.height)
        }
        /// mask动画
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = beginPath.cgPath
        animation.toValue = finalPath.cgPath
        animation.duration = HXSuspendViewConfig.animateDuration
        animation.delegate = self
        maskLayer.add(animation, forKey: "path")
        /// 改变悬浮窗alpha
        changeSuspendViewAlpha(1, animated: true)
        self.fakerImageView = fakerImageView
    }
    
}

// MARK: -  HXSuspendWindowDelegate
extension HXSuspendViewManager: HXSuspendWindowDelegate {
    
    func suspendWindowDidTap(_ suspendWindow: HXSuspendWindow) {
        guard let viewController = suspendWindow.viewContoller as? UIViewController else { return }
        hx_topViewController()?.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

// MARK: -  CAAnimationDelegate
extension HXSuspendViewManager: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        fakerImageView?.removeFromSuperview()
        fakerImageView = nil
    }
    
}
