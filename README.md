# HXSuspendViewManager
iOS仿微信的悬浮窗，自定义转场动画，使用超级简单

## 先看看效果图
![image](https://github.com/hxwxww/HXSuspendViewManager/raw/master/screenshots/screenshot1.gif)

![image](https://github.com/hxwxww/HXSuspendViewManager/raw/master/screenshots/screenshot2.gif)

## 代码结构
![代码结构.jpg](https://upload-images.jianshu.io/upload_images/4068337-3d12219e4b752378.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

- HXSuspendViewManager是一个单例，负责主要的逻辑，控制悬浮窗和扇形view的生命周期、展示和隐藏。
- HXSuspendViewController是一个协议，只要你的控制器遵守了这个协议，你的控制器就可以添加到悬浮窗中。
- UINavigationController+HXSuspend是UINavigationController的分类，悬浮窗相关的处理逻辑都在这里。
- HXCircleTransition是自定义转场动画类
- HXSuspendWindow悬浮窗的视图，继承自UIWindow
- HXCircularSectorView右下角的扇形view

## 实现原理
- 拦截UINavigationController的右滑返回手势，判断是否显示右下角的扇形view，主要包括三个方法，这三个方法都通过runtime交换了方法实现
```
open override func viewDidLoad() {
super.viewDidLoad()
UINavigationController.initializeSuspendOnce()
interactivePopGestureRecognizer?.delegate = self
delegate = self
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
```
滑动中：hx_updateInteractiveTransition:
滑动结束，并完成pop：hx_finishInteractiveTransition:transitionContext:
滑动结束，取消了pop：hx_cancelInteractiveTransition:transitionContext:
具体实现如下：
```
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
// 播放一个假的转场动画
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
```
- 实现自定义的转场动画，通过UINavigationControllerDelegate代理实现
```
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
// 保证是suspendWindow所持有的viewController
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
```

## 其他细节
- 悬浮窗的拖动处理
```
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
```
- 转场动画的具体实现，pop的实现同理
```
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
```
## 使用方法
超级简单的使用方法，完全无侵入。
```

class VipcnViewController: UIViewController, HXSuspendViewController {

// MARK: -  HXSuspendViewController
var suspendIdentifier: Int {
// 保证suspendIdentifier唯一
return hashValue
}

var suspendIcon: UIImage? {
return UIImage(named: "2")
}

}
```
就是这么简单，只需要让你的控制器遵守HXSuspendViewController协议就行了。

## 总结
iOS仿微信的悬浮窗，自定义转场动画，集成超级简单。
如果觉得对你有帮助，请给个star。
