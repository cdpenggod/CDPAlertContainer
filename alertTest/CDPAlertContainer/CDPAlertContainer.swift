//
//  CDPAlertContainer.swift
//  alertTest
//
//  Created by chaidongpeng on 2022/9/26.
//  alert弹层容器
//
//  进入/退出弹层，调用相关 appear/disappear 类方法就行
//  或者 退出时自己直接调用 -(void)dismissViewControllerAnimated:completion: 方法

import UIKit

@objc protocol CDPAlertContainerDelegate: NSObjectProtocol {
    /// 点击背景蒙层回调
    /// - container: 弹层容器
    @objc optional func alertContainerDidClickDimming(container: CDPAlertContainer)
    
    /// 返回 弹层出现方式 (优先级高于 .presentType 属性，会同步修改该属性)
    /// - Returns: 弹层出现方式
    @objc optional func alertContainerPresentType(container: CDPAlertContainer) -> CDPAlertPresentType
    
    /// 返回 弹层消失方式 (优先级高于 .dismissType 属性，会同步修改该属性)
    /// - Returns: 弹层出现方式
    @objc optional func alertContainerDismissType(container: CDPAlertContainer) -> CDPAlertDismissType
}

@objcMembers
class CDPAlertContainer: UIViewController {
    /// 代理
    public weak var delegate: CDPAlertContainerDelegate? = nil
    
    /// 弹层出现方式 (默认 .bottom)
    public var presentType: CDPAlertPresentType = .bottom {
        didSet {
            guard let delegate = transitioningDelegate as? CDPAlertPresentationController else { return }
            delegate.presentType = presentType
        }
    }
    /// 弹层消失方式 (默认 .bottom)
    public var dismissType: CDPAlertDismissType = .bottom {
        didSet {
            guard let delegate = transitioningDelegate as? CDPAlertPresentationController else { return }
            delegate.dismissType = dismissType
        }
    }
    /// 弹层左右距离屏幕边距 (默认 40)
    public var alertMargin: CGFloat = 40 {
        didSet {
            preferredContentSize = CGSize(width: max(0, UIScreen.main.bounds.width - alertMargin * 2), height: max(0, alertHeight))
        }
    }
    /// 弹层高度 (默认 240)
    public var alertHeight: CGFloat = 240 {
        didSet {
            preferredContentSize = CGSize(width: max(0, UIScreen.main.bounds.width - alertMargin * 2), height: max(0, alertHeight))
        }
    }
    /// 背景蒙层透明度 (默认 0.5)
    public var dimmingAlpha: CGFloat = 0.5 {
        didSet {
            guard let delegate = transitioningDelegate as? CDPAlertPresentationController else { return }
            delegate.dimmingAlpha = dimmingAlpha
        }
    }
    /// 背景蒙层颜色，如果不想显示背景但需要点击消失，可设为.clear (默认 .black)
    public var dimmingColor: UIColor = .black {
        didSet {
            guard let delegate = transitioningDelegate as? CDPAlertPresentationController else { return }
            delegate.dimmingColor = dimmingColor
        }
    }
    /// 背景蒙层是否可点击使弹层消失 (默认 YES)
    public var dimmingCanClickDisappear: Bool = true {
        didSet {
            guard let delegate = transitioningDelegate as? CDPAlertPresentationController else { return }
            delegate.dimmingCanClickDisappear = dimmingCanClickDisappear
        }
    }
    /// 过渡动画时长 (默认 0.3)
    public var duration: TimeInterval = 0.3 {
        didSet {
            guard let delegate = transitioningDelegate as? CDPAlertPresentationController else { return }
            delegate.duration = duration
        }
    }
    /// 弹层圆角 (默认 8)
    public var cornerRadius: CGFloat = 8 {
        didSet {
            guard let delegate = transitioningDelegate as? CDPAlertPresentationController else { return }
            delegate.cornerRadius = cornerRadius
        }
    }
    /// 弹层masksToBounds
    public var masksToBounds: Bool = true {
        didSet {
            guard let delegate = transitioningDelegate as? CDPAlertPresentationController else { return }
            delegate.masksToBounds = masksToBounds
        }
    }
    /// 最外层是否拥有阴影 (默认 NO)
    public var haveShadow: Bool = false {
        didSet {
            guard let delegate = transitioningDelegate as? CDPAlertPresentationController else { return }
            delegate.haveShadow = haveShadow
        }
    }
    /// 阴影Opacity (默认 0.44)
    public var shadowOpacity: CGFloat = 0.44 {
        didSet {
            guard let delegate = transitioningDelegate as? CDPAlertPresentationController else { return }
            delegate.shadowOpacity = shadowOpacity
        }
    }
    /// 阴影Radius (默认 13)
    public var shadowRadius: CGFloat = 13 {
        didSet {
            guard let delegate = transitioningDelegate as? CDPAlertPresentationController else { return }
            delegate.shadowRadius = shadowRadius
        }
    }
    /// 阴影Offset (默认 CGSize(width: 0, height: -6))
    public var shadowOffset: CGSize = CGSize(width: 0, height: -6) {
        didSet {
            guard let delegate = transitioningDelegate as? CDPAlertPresentationController else { return }
            delegate.shadowOffset = shadowOffset
        }
    }
    /// 阴影颜色 (默认 .black)
    public var shadowColor: UIColor = .black {
        didSet {
            guard let delegate = transitioningDelegate as? CDPAlertPresentationController else { return }
            delegate.shadowColor = shadowColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //弹层整体背景色
        view.backgroundColor = .white
        //设置内容size
        preferredContentSize = CGSize(width: max(0, UIScreen.main.bounds.width - alertMargin * 2), height: max(0, alertHeight))
    }
    
    /// 即将进行过渡
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        preferredContentSize = CGSize(width: max(0, UIScreen.main.bounds.width - alertMargin * 2), height: max(0, alertHeight))
    }
}

//MARK: - 调起弹层/退出弹层
extension CDPAlertContainer {
    /// 调起弹层
    /// - Parameters:
    ///   - contentView: 弹层上要添加的内容view，自己设置frame
    ///   - fromVC: 调起弹层的viewController
    ///   - alertHeight: 弹层整体高度
    public class func appear(contentView: UIView, fromVC: UIViewController, alertHeight: CGFloat = 240) {
        appear(contentView: contentView, fromVC: fromVC) { container in
            container.alertHeight = max(0, alertHeight)
        }
    }
    
    /// 调起弹层
    /// - Parameters:
    ///   - contentView: 弹层上要添加的内容view，自己设置frame 或 在 config回调 里设置自适应
    ///   - fromVC: 调起弹层的viewController
    ///   - config: 配置回调，用于吊起弹层前的一些自定义设置
    public class func appear(contentView: UIView, fromVC: UIViewController, config: ((CDPAlertContainer) -> Void)?) {
        appear(contentView: contentView, fromVC: fromVC, config: config, completion: nil)
    }
    
    /// 调起弹层
    /// - Parameters:
    ///   - contentView: 弹层上要添加的内容view，自己设置frame 或 在 config回调 里设置自适应
    ///   - fromVC: 调起弹层的viewController
    ///   - config: 配置回调，用于吊起弹层前的一些自定义设置
    ///   - completion: 弹层调起完成回调
    public class func appear(contentView: UIView, fromVC: UIViewController, config: ((CDPAlertContainer) -> Void)?, completion: (() -> Void)?) {
        //生成弹层容器
        let container = CDPAlertContainer()
        //添加内容view
        container.view.addSubview(contentView)
        //设置过渡处理类
        let presentationController = CDPAlertPresentationController(presentedViewController: container, presenting: fromVC)
        container.transitioningDelegate = presentationController
        //背景点击回调
        presentationController.dimmingClickBeforeDisappear = { [weak container] in
            guard let container = container else { return }
            container.delegate?.alertContainerDidClickDimming?(container: container)
        }
        //即将过渡回调
        presentationController.willBeginTransition = { [weak container] isPresenting in
            guard let container = container else { return }
            if isPresenting {
                if let type = container.delegate?.alertContainerPresentType?(container: container) {
                    container.presentType = type
                }
            } else {
                if let type = container.delegate?.alertContainerDismissType?(container: container) {
                    container.dismissType = type
                }
            }
        }
        //配置container
        config?(container)
        //调起弹层
        fromVC.present(container, animated: true, completion: completion)
    }
    
    /// 退出最顶层的弹层
    /// - Parameters:
    ///   - animated: 是否进行动画
    ///   - completion: 弹层退出完成回调
    public class func disappear(animated: Bool, completion: (() -> Void)?) {
        guard let vc = getCurrentVC() else { return }
        vc.dismiss(animated: animated, completion: completion)
    }
}

//MARK: - 获取VC方法
private extension CDPAlertContainer {
    /// 获取当前顶层VC
    /// - Returns: 当前顶层VC
    class private func getCurrentVC() -> UIViewController? {
        var keyWindow: UIWindow? = nil
        
        // 向下兼容iOS13之前创建的项目
        if let window = UIApplication.shared.delegate?.window {
            keyWindow = window
        } else {
            // iOS13及以后，可多窗口，优先使用活动窗口的keyWindow
            if #available(iOS 13.0, *) {
                let activeWindowScene = UIApplication.shared
                    .connectedScenes
                    .filter { $0.activationState == .foregroundActive }
                    .first
                if let windowScene = activeWindowScene as? UIWindowScene {
                    keyWindow = windowScene.windows.first { $0.isKeyWindow }
                }
            } else {
                keyWindow = UIApplication.shared.keyWindow
            }
        }
        
        if keyWindow == nil {
            keyWindow = UIApplication.shared.windows.first { $0.isKeyWindow }
        }
        return getVisibleVC(viewController: keyWindow?.rootViewController)
    }
    
    /// 根据viewController获取其当前可见VC
    /// - Parameter viewController: 总VC
    /// - Returns: 可见VC
    class private func getVisibleVC(viewController: UIViewController?) -> UIViewController? {
        if let nvc =  viewController as? UINavigationController {
            return getVisibleVC(viewController: nvc.visibleViewController)
        } else if let tabbarController = viewController as? UITabBarController {
            return getVisibleVC(viewController: tabbarController.selectedViewController)
        } else {
            guard let presentedVC = viewController?.presentedViewController else {
                return viewController
            }
            return getVisibleVC(viewController: presentedVC)
        }
    }
}
