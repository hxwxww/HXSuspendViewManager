//
//  UINavigationController+HXSuspend.swift
//  HXSuspendViewManager
//
//  Created by HongXiangWen on 2018/12/30.
//  Copyright © 2018年 WHX. All rights reserved.
//

import UIKit

// MARK: -  专门处理悬浮窗相关逻辑
extension UINavigationController {
    
    private struct AssociatedKeys {
        static var poppingVC = "AssociatedKeys_popingVC"
    }
    
    var hx_poppingVC: UIViewController? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.poppingVC) as? UIViewController
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.poppingVC, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        UINavigationController.initializeSuspendOnce()
        if isMember(of: UINavigationController.self) {
            interactivePopGestureRecognizer?.delegate = self
            delegate = self
        }
    }
    
    private static let onceToken = UUID().uuidString
    private static func initializeSuspendOnce() {
        guard self == UINavigationController.self else { return }
        DispatchQueue.hx_once(onceToken) {
            let needSwizzleSelectorArr = [
                NSSelectorFromString("_updateInteractiveTransition:"),
                NSSelectorFromString("_finishInteractiveTransition:transitionContext:"),
                NSSelectorFromString("_cancelInteractiveTransition:transitionContext:"),
                NSSelectorFromString("popViewControllerAnimated:"),
                NSSelectorFromString("popToRootViewControllerAnimated:"),
                NSSelectorFromString("popToViewController:animated:")
            ]
            for selector in needSwizzleSelectorArr {
                let newSelector = ("hx_" + selector.description).replacingOccurrences(of: "__", with: "_")
                let originalMethod = class_getInstanceMethod(self, selector)
                let swizzledMethod = class_getInstanceMethod(self, Selector(newSelector))
                if originalMethod != nil && swizzledMethod != nil {
                    method_exchangeImplementations(originalMethod!, swizzledMethod!)
                }
            }
        }
    }
    
    @objc func hx_popViewControllerAnimated(_ animated: Bool) -> UIViewController? {
        hx_poppingVC = topViewController
        return hx_popViewControllerAnimated(animated)
    }
    
    @objc func hx_popToRootViewControllerAnimated(_ animated: Bool) -> [UIViewController]? {
        hx_poppingVC = topViewController
        return hx_popToRootViewControllerAnimated(animated)
    }
    
    @objc func hx_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        hx_poppingVC = topViewController
        return hx_popToViewController(viewController, animated: animated)
    }
    
    @objc func hx_updateInteractiveTransition(_ percentComplete: CGFloat) {
        hx_updateInteractiveTransition(percentComplete)
        guard let poppingVC = hx_poppingVC as? HXSuspendViewController,
            let keyWindow = UIApplication.shared.keyWindow,
            let point = interactivePopGestureRecognizer?.location(in: keyWindow) else { return }
        /// 添加右下角扇形view
        if HXSuspendViewManager.shared.circularSectorView.superview == nil {
            keyWindow.addSubview(HXSuspendViewManager.shared.circularSectorView)
        }
        /// 如果是新的控制器，显示扇形，否则显示悬浮窗
        if poppingVC.suspendIdentifier != HXSuspendViewManager.shared.suspendWindow?.viewContoller?.suspendIdentifier {
            HXSuspendViewManager.shared.circularSectorView.type = .add
            HXSuspendViewManager.shared.circularSectorView.show(percent: percentComplete)
            HXSuspendViewManager.shared.circularSectorView.move(point: point)
        } else {
            HXSuspendViewManager.shared.changeSuspendViewAlpha(percentComplete, animated: false)
        }
    }
    
    @objc func hx_finishInteractiveTransition(_ percentComplete: CGFloat, transitionContext: UIViewControllerContextTransitioning)  {
        hx_finishInteractiveTransition(percentComplete, transitionContext: transitionContext)
        /// 保证最后一定调用隐藏扇形view
        defer {
            HXSuspendViewManager.shared.circularSectorView.hide()
        }
        guard let poppingVC = hx_poppingVC as? HXSuspendViewController,
            let keyWindow = UIApplication.shared.keyWindow,
            let point = interactivePopGestureRecognizer?.location(in: keyWindow) else { return }
        if poppingVC.suspendIdentifier != HXSuspendViewManager.shared.suspendWindow?.viewContoller?.suspendIdentifier {
            /// 添加新的悬浮窗
            if HXSuspendViewManager.shared.circularSectorView.isPointInView(point: point) {
                HXSuspendViewManager.shared.addSuspendView(viewController: poppingVC, percent: percentComplete)
            }
        } else {
            HXSuspendViewManager.shared.fakeTransitionAnimation(percentComplete)
        }
    }
    
    @objc func hx_cancelInteractiveTransition(_ percentComplete: CGFloat, transitionContext: UIViewControllerContextTransitioning) {
        hx_cancelInteractiveTransition(percentComplete, transitionContext: transitionContext)
        defer {
            HXSuspendViewManager.shared.circularSectorView.hide()
        }
        guard let poppingVC = hx_poppingVC as? HXSuspendViewController else { return }
        if poppingVC.suspendIdentifier == HXSuspendViewManager.shared.suspendWindow?.viewContoller?.suspendIdentifier  {
            HXSuspendViewManager.shared.changeSuspendViewAlpha(0, animated: false)
        } else {
            HXSuspendViewManager.shared.changeSuspendViewAlpha(1, animated: false)
        }
    }
    
}

// MARK: -  UINavigationControllerDelegate
extension UINavigationController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        hx_poppingVC = nil
    }
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let suspendWindow = HXSuspendViewManager.shared.suspendWindow,
            let currentSuspendVC = suspendWindow.viewContoller else { return nil }
        switch operation {
        case .push:
            guard let suspendToVC = toVC as? HXSuspendViewController,
                suspendToVC.suspendIdentifier == currentSuspendVC.suspendIdentifier else { return nil }
            return HXCircleTransition(operationType: .push, originPoint: suspendWindow.center)
        case .pop:
            guard let suspendFromVC = fromVC as? HXSuspendViewController,
                suspendFromVC.suspendIdentifier == currentSuspendVC.suspendIdentifier else { return nil }
            return HXCircleTransition(operationType: .pop, originPoint: suspendWindow.center)
        default:
            return nil
        }
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension UINavigationController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
    
}
