//
//  UIView+HXTools.swift
//  HXTools
//
//  Created by HongXiangWen on 2018/12/21.
//  Copyright © 2018年 WHX. All rights reserved.
//

import UIKit

// MARK: -  UIView通用封装
extension UIView {
    
    /// 获取所属的viewController
    var hx_viewController: UIViewController? {
        var nextView: UIView? = self
        while nextView?.superview != nil {
            nextView = nextView?.superview
            if let nextResponder = nextView?.next, let viewController = nextResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    /// 移除指定类型的子视图
    ///
    /// - Parameter subviewClass: 需要移除的子视图类型，默认为UIView
    func hx_removeSubviews(_ subviewClass: AnyClass = UIView.self) {
        for subview in self.subviews {
            if subview.isKind(of: subviewClass) {
                subview.removeFromSuperview()
            }
        }
    }
    
    /// 获取截图
    ///
    /// - Parameters:
    ///   - rect: 截图范围，默认为CGRect.zero
    ///   - scale: 图片缩放因子，默认为屏幕缩放因子
    /// - Returns: 截图
    func hx_snapshotImage(_ rect: CGRect = .zero, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        // 获取整个区域图片
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        drawHierarchy(in: frame, afterScreenUpdates: true)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        // 如果不裁剪图片，直接返回整张图片
        if rect.equalTo(.zero) || rect.equalTo(bounds) {
            return image
        }
        // 按照给定的矩形区域进行剪裁
        guard let sourceImageRef = image.cgImage else { return nil }
        let newRect = rect.applying(CGAffineTransform(scaleX: scale, y: scale))
        guard let newImageRef = sourceImageRef.cropping(to: newRect) else { return nil }
        // 将CGImageRef转换成UIImage
        let newImage = UIImage(cgImage: newImageRef, scale: scale, orientation: .up)
        return newImage
    }
    
}
