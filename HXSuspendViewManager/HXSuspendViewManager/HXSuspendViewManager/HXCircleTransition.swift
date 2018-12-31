//
//  HXCircleTransition.swift
//  HXSuspendViewManager
//
//  Created by HongXiangWen on 2018/12/30.
//  Copyright © 2018年 WHX. All rights reserved.
//

import UIKit

// MARK: -  navigation转场类型
enum HXNavigationTransitionOperationType {
    case push
    case pop
    case custom
    case none
}

// MARK: -  present转场类型
enum HXPresentationTransitionOperationType {
    case present
    case dismiss
    case none
}


class HXCircleTransition: NSObject {
    
    private var originPoint: CGPoint = .zero
    private var operationType: HXNavigationTransitionOperationType = .none
    private weak var transitionContext: UIViewControllerContextTransitioning?

    init(operationType: HXNavigationTransitionOperationType, originPoint: CGPoint) {
        self.operationType = operationType
        self.originPoint = originPoint
    }

}

// MARK: -  Private Methods
extension HXCircleTransition {
    
    private func pushAnimation(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                completeTransition(transitionContext: transitionContext)
                HXSuspendViewManager.shared.changeSuspendViewAlpha(0, animated: false)
                return
        }
        // 添加到containerView中
        let containerView = transitionContext.containerView
        containerView.addSubview(fromVC.view)
        containerView.addSubview(toVC.view)
        // 计算path
        let originSize = HXSuspendViewConfig.suspendViewSize
        let originFrame = CGRect(x: originPoint.x - originSize.width / 2, y: originPoint.y - originSize.height / 2, width: originSize.width, height: originSize.height)
        let beginPath = UIBezierPath(ovalIn: originFrame)
        let finalRadius = HXCircleTransition.radius(with: originPoint)
        let finalPath = UIBezierPath(ovalIn: originFrame.insetBy(dx: -finalRadius, dy: -finalRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = finalPath.cgPath
        toVC.view.layer.mask = maskLayer
        // 开始动画
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = beginPath.cgPath
        animation.toValue = finalPath.cgPath
        animation.duration = transitionDuration(using: transitionContext)
        animation.delegate = self
        maskLayer.add(animation, forKey: "path")
        // 改变悬浮窗alpha
        HXSuspendViewManager.shared.changeSuspendViewAlpha(0, animated: true)
    }
    
    private func popAnimation(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else {
                completeTransition(transitionContext: transitionContext)
                HXSuspendViewManager.shared.changeSuspendViewAlpha(1, animated: false)
                return
        }
        let containerView = transitionContext.containerView
        containerView.addSubview(toVC.view)
        containerView.addSubview(fromVC.view)
        let originSize = HXSuspendViewConfig.suspendViewSize
        let originFrame = CGRect(x: originPoint.x - originSize.width / 2, y: originPoint.y - originSize.height / 2, width: originSize.width, height: originSize.height)
        let finalPath = UIBezierPath(ovalIn: originFrame)
        let beginRadius = HXCircleTransition.radius(with: originPoint)
        let beginPath = UIBezierPath(ovalIn: originFrame.insetBy(dx: -beginRadius, dy: -beginRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.path = finalPath.cgPath
        fromVC.view.layer.mask = maskLayer
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = beginPath.cgPath
        animation.toValue = finalPath.cgPath
        animation.duration = transitionDuration(using: transitionContext)
        animation.delegate = self
        maskLayer.add(animation, forKey: "path")
        HXSuspendViewManager.shared.changeSuspendViewAlpha(1, animated: true)
    }
    
    /// 结束动画
    private func completeTransition(transitionContext: UIViewControllerContextTransitioning?) {
        guard let transitionContext = transitionContext else { return }
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
    
}

// MARK: -  UIViewControllerAnimatedTransitioning
extension HXCircleTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return HXSuspendViewConfig.animateDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        switch operationType {
        case .push:
            pushAnimation(transitionContext: transitionContext)
        case .pop:
            popAnimation(transitionContext: transitionContext)
        default:
            completeTransition(transitionContext: transitionContext)
        }
    }
    
}

// MARK: -  CAAnimationDelegate
extension HXCircleTransition: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        completeTransition(transitionContext: transitionContext)
    }
    
    class func radius(with point: CGPoint) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        var radius: CGFloat = 0
        // 以screenWidth/2,screenHeight/2为原点，计算象限
        if point.x >= screenWidth / 2 {
            if point.y >= screenHeight / 2 {
                // 第四象限
                radius = sqrt(point.x * point.x  + point.y * point.y)
            } else {
                // 第一象限
                radius = sqrt(point.x * point.x  + (screenHeight - point.y) * (screenHeight - point.y))
            }
        } else {
            if point.y >= screenHeight / 2 {
                // 第三象限
                radius = sqrt((screenWidth - point.x) * (screenWidth - point.x) + point.y * point.y)
            } else {
                // 第二象限
                radius = sqrt((screenWidth - point.x) * (screenWidth - point.x) + (screenHeight - point.y) * (screenHeight - point.y))
            }
        }
        return radius
    }
    
}
