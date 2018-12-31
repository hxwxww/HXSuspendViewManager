//
//  HXCircularSectorView.swift
//  HXSuspendViewManager
//
//  Created by HongXiangWen on 2018/12/30.
//  Copyright © 2018年 WHX. All rights reserved.
//

import UIKit

enum HXCircularSectorViewType {
    case add       // 添加悬浮窗
    case delete    // 移除悬浮窗
}

// MARK: -  右下角扇形view
class HXCircularSectorView: UIView {
    
    var type: HXCircularSectorViewType = .add {
        didSet {
            sectorLayer.fillColor = type == .add ? UIColor.lightGray.cgColor : UIColor.red.cgColor
            textLabel.text = type == .add ? "添加浮窗" : "取消浮窗"
        }
    }
    
    private lazy var textLabel: UILabel = {
        let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        textLabel.font = UIFont.systemFont(ofSize: 15)
        textLabel.textAlignment = .center
        textLabel.text = type == .add ? "添加浮窗" : "取消浮窗"
        textLabel.textColor = .white
        return textLabel
    }()
    
    private lazy var sectorLayer: CAShapeLayer = {
        let arcWidth = min(bounds.width, bounds.height)
        let arcCenter = CGPoint(x: bounds.width, y: bounds.height)
        let path = UIBezierPath(arcCenter: arcCenter, radius: arcWidth, startAngle: -CGFloat(Double.pi) / 2, endAngle: CGFloat(Double.pi), clockwise: false)
        path.addLine(to: arcCenter)
        path.close()
        let sectorLayer = CAShapeLayer()
        sectorLayer.frame = bounds
        sectorLayer.fillColor = type == .add ? UIColor.lightGray.cgColor : UIColor.orange.cgColor
        sectorLayer.path = path.cgPath
        return sectorLayer
    }()
    
    init(frame: CGRect, type: HXCircularSectorViewType) {
        super.init(frame: frame)
        self.type = type
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 设置透明背景
        backgroundColor = .clear
        // 添加扇形背景
        layer.addSublayer(sectorLayer)
        // 添加提示文字
        textLabel.center = CGPoint(x: frame.width * 0.6, y: frame.height * 0.6)
        addSubview(textLabel)
    }
    
}

// MARK: -  Public Methods
extension HXCircularSectorView {
    
    func show(percent: CGFloat) {
        let originX = hx_screenWidth - bounds.width * min(percent * 2, 1)
        let originY = hx_screenHeight - bounds.height * min(percent * 2, 1)
        frame = CGRect(x: originX, y: originY, width: bounds.width, height: bounds.height)
    }
    
    func show() {
        UIView.animate(withDuration: 0.2) {
            self.frame = CGRect(x: hx_screenWidth - self.bounds.width, y: hx_screenHeight - self.bounds.height, width: self.bounds.width, height: self.bounds.height)
        }
    }
    
    func move(point: CGPoint) {
        var animateTransform: CATransform3D
        if isPointInView(point: point) {
            animateTransform = CATransform3DMakeScale(1.3, 1.3, 1)
        } else {
            animateTransform = CATransform3DIdentity
        }
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.animate(withDuration: 0.2) {
            self.sectorLayer.transform = animateTransform
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2) {
            self.frame = CGRect(x: hx_screenWidth, y: hx_screenHeight, width: self.bounds.width, height: self.bounds.height)
        }
    }
 
    func isPointInView(point: CGPoint) -> Bool {
        let convertFrame = sectorLayer.convert(sectorLayer.bounds, to: nil)
        let convertPoint = CGPoint(x: point.x - convertFrame.minX, y: point.y - convertFrame.minY)
        let path = UIBezierPath(cgPath: sectorLayer.path!)
        return path.contains(convertPoint)
    }
    
}

