//
//  UIImage+HXTools.swift
//  HXTools
//
//  Created by HongXiangWen on 2018/12/25.
//  Copyright © 2018年 WHX. All rights reserved.
//

import UIKit

extension UIImage {
    
    /// 通过颜色生成图片
    ///
    /// - Parameters:
    ///   - color: 颜色
    ///   - size: 图片尺寸
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(size)
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        guard let image = UIGraphicsGetImageFromCurrentImageContext(),
            let imageRef = image.cgImage else { return nil }
        self.init(cgImage: imageRef)
    }
    
    /// 获取图片某一点的颜色
    ///
    /// - Parameter point: 目标点，x、y为0-1之间的数，表示在图片中的点的比例位置
    /// - Returns: 得到的颜色
    func hx_color(at point: CGPoint) -> UIColor? {
        guard let imageRef = cgImage else { return nil }
        let realPointX = Int(CGFloat(imageRef.width) * point.x) + 1
        let realPointY = Int(CGFloat(imageRef.height) * point.y) + 1
        let rect = CGRect(x: 0, y: 0, width: CGFloat(imageRef.width), height: CGFloat(imageRef.height))
        let realPoint = CGPoint(x: realPointX, y: realPointY)
        guard rect.contains(realPoint) else { return nil }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        let pixelData = UnsafeMutablePointer<UInt8>.allocate(capacity: 4)
        guard let context = CGContext(data: pixelData, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo) else { return nil }
        context.setBlendMode(.copy)
        context.translateBy(x:  -CGFloat(realPointX), y: CGFloat(realPointY - imageRef.height))
        context.draw(imageRef, in: rect)
        let red = CGFloat(pixelData[0]) / 255
        let green = CGFloat(pixelData[1]) / 255
        let blue = CGFloat(pixelData[2]) / 255
        let alpha = CGFloat(pixelData[3]) / 255
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
}

extension UIImage {
    
    /// 按比例缩放图片
    ///
    /// - Parameter scale: 缩放比例
    /// - Returns: 缩放后的图片
    func hx_resize(with scale: CGFloat) -> UIImage {
        let newSize = size.applying(CGAffineTransform(scaleX: scale, y: scale))
        return hx_resize(to: newSize)
    }
    
    /// 图片缩放到指定尺寸
    ///
    /// - Parameter newSize: 新尺寸
    /// - Returns: 缩放后的图片
    func hx_resize(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        defer {
            UIGraphicsEndImageContext()
        }
        draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        return newImage
    }

}
