//
//  HXSuspendWindow.swift
//  HXSuspendViewManager
//
//  Created by HongXiangWen on 2018/12/30.
//  Copyright © 2018年 WHX. All rights reserved.
//

import UIKit

protocol HXSuspendWindowDelegate: class {
    func suspendWindowDidTap(_ suspendWindow: HXSuspendWindow)
}

// MARK: -  悬浮窗，继承于UIWindow
class HXSuspendWindow: UIWindow {
    
    weak var delegate: HXSuspendWindowDelegate?
    
    var viewContoller: HXSuspendViewController? {
        didSet {
            coverImageView.image = viewContoller?.suspendIcon
        }
    }
    
    private lazy var coverImageView: UIImageView = {
        let coverImageView = UIImageView(frame: bounds)
        coverImageView.layer.cornerRadius = bounds.width / 2
        coverImageView.layer.borderColor = HXSuspendViewConfig.suspendBorderColor.cgColor
        coverImageView.layer.borderWidth = 5
        coverImageView.layer.masksToBounds = true
        return coverImageView
    }()
    
    private var panStartPoint: CGPoint = .zero
    private var panStartCenter: CGPoint = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.rootViewController = UIViewController()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: -  Private Methods
extension HXSuspendWindow {
    
    private func setupUI() {
        alpha = 0
        clipsToBounds = true
        isUserInteractionEnabled = true
        windowLevel = UIWindow.Level.alert - 1
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap(gesture:))))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPan(gesture:))))
        addSubview(coverImageView)
    }
    
    @objc private func didTap(gesture: UITapGestureRecognizer) {
        delegate?.suspendWindowDidTap(self)
    }
    
    @objc private func didPan(gesture: UIPanGestureRecognizer) {
        let point = gesture.location(in: UIApplication.shared.keyWindow)
        switch gesture.state {
        case .began:
            panStartPoint = point
            panStartCenter = center
            HXSuspendViewManager.shared.circularSectorView.type = .delete
            HXSuspendViewManager.shared.circularSectorView.show()
        case .changed:
            let panDeltaX = point.x - panStartPoint.x
            let panDeltaY = point.y - panStartPoint.y
            let centerX = min(max(panStartCenter.x + panDeltaX, bounds.width / 2), hx_screenWidth - bounds.width / 2)
            let centerY = min(max(panStartCenter.y + panDeltaY, bounds.height / 2), hx_screenHeight - bounds.height / 2 )
            center = CGPoint(x: centerX, y: centerY)
            HXSuspendViewManager.shared.circularSectorView.move(point: center)
        default:
            if HXSuspendViewManager.shared.circularSectorView.isPointInView(point: center) {
                HXSuspendViewManager.shared.removeSuspendView()
            } else {
                // 保证悬浮窗在安全范围之内
                let centerX = min(max(center.x, bounds.width / 2 + 10), hx_screenWidth - bounds.width / 2 - 10)
                let centerY = min(max(center.y, bounds.height / 2 + hx_statusBarHeight), hx_screenHeight - bounds.height / 2 - hx_safeBottomHeight)
                UIView.animate(withDuration: 0.2) {
                    self.center = CGPoint(x: centerX, y: centerY)
                }
            }
            HXSuspendViewManager.shared.circularSectorView.hide()
        }
    }
    
}
