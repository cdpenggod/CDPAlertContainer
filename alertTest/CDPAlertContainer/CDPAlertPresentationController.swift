//
//  CDPAlertPresentationController.swift
//  alertTest
//
//  Created by chaidongpeng on 2022/9/26.
//  alert弹层容器-过渡管理类

import UIKit

/// 弹层出现方式
@objc public enum CDPAlertPresentType: Int {
    /// 从底部到屏幕中间
    case bottom    = 0
    /// 从顶部到屏幕中间
    case top       = 1
    /// 在屏幕中间缩放出现
    case zoom      = 2
    /// 在屏幕中间缩放并渐隐出现
    case zoomAlpha = 3
    /// 直接出现在屏幕中间 (无动画)
    case nothing   = 4
}

/// 弹层消失方式
@objc public enum CDPAlertDismissType: Int {
    /// 从屏幕中间到底部
    case bottom    = 0
    /// 从屏幕中间到顶部
    case top       = 1
    /// 在屏幕中间缩放消失
    case zoom      = 2
    /// 在屏幕中间缩放并渐隐消失
    case zoomAlpha = 3
    /// 在屏幕中间直接消失 (无动画)
    case nothing   = 4
}

@objcMembers
class CDPAlertPresentationController: UIPresentationController {
    /// 即将开始过渡回调 (Bool：YES 当前为 present过渡，NO 当前为 dismiss过渡)
    public var willBeginTransition: ((Bool) -> Void)? = nil
    
    /// 弹层出现方式 (默认 .bottom)
    public var presentType: CDPAlertPresentType = .bottom
    /// 弹层消失方式 (默认 .bottom)
    public var dismissType: CDPAlertDismissType = .bottom
    
    /// 背景蒙层点击回调
    public var dimmingClickBeforeDisappear: (() -> Void)? = nil
    /// 背景蒙层透明度
    public var dimmingAlpha: CGFloat = 0.5
    /// 背景蒙层颜色
    public var dimmingColor: UIColor = .black
    /// 背景蒙层是否可点击使弹层消失
    public var dimmingCanClickDisappear: Bool = true
    /// 过渡动画时长
    public var duration: TimeInterval = 0.3
    /// 弹层圆角
    public var cornerRadius: CGFloat = 8
    /// 最外层是否拥有阴影
    public var haveShadow: Bool = false
    /// 阴影Opacity
    public var shadowOpacity: CGFloat = 0.44
    /// 阴影Radius
    public var shadowRadius: CGFloat = 13
    /// 阴影Offset
    public var shadowOffset: CGSize = CGSize(width: 0, height: -6)
    /// 阴影颜色
    public var shadowColor: UIColor = .black
    
    /// 背景蒙层
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = dimmingColor
        view.isOpaque = false
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(dimmingClick))
        view.addGestureRecognizer(tapGR)
        return view
    }()
    /// 最外层阴影
    private lazy var shadowView: UIView? = nil
    
    override var presentedView: UIView? {
        return shadowView
    }
    
    ///  过渡结束后presentedView在containerView中的frame
    override var frameOfPresentedViewInContainerView: CGRect {
        //获取containerView的宽高
        let containerViewBounds: CGRect = containerView?.bounds ?? .zero
        //获取presentedView实际内容所需宽高
        let presentedViewContentSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerViewBounds.size)
        
        //根据实际宽高更新y与高度
        var presentedViewControllerFrame = containerViewBounds
        presentedViewControllerFrame.size = presentedViewContentSize
        presentedViewControllerFrame.origin.x = (containerViewBounds.maxX - presentedViewContentSize.width) / 2.0
        presentedViewControllerFrame.origin.y = (containerViewBounds.maxY - presentedViewContentSize.height) / 2.0
        return presentedViewControllerFrame
    }
    
    /// 初始化
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        //设置自定义模式
        presentedViewController.modalPresentationStyle = .custom
    }
    
    /// 即将开始present过渡
    override func presentationTransitionWillBegin() {
        guard let presentedViewControllerView = super.presentedView else { return }
        
        //更新阴影
        shadowView = UIView(frame: frameOfPresentedViewInContainerView)
        if haveShadow {
            shadowView?.layer.shadowOpacity = max(0, Float(shadowOpacity))
            shadowView?.layer.shadowRadius = max(0, shadowRadius)
            shadowView?.layer.shadowOffset = shadowOffset
            shadowView?.layer.shadowColor = shadowColor.cgColor
        }
        
        //更新过渡后的view
        presentedViewControllerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //圆角
        presentedViewControllerView.layer.masksToBounds = true
        presentedViewControllerView.layer.cornerRadius = max(0, cornerRadius)
        presentedViewControllerView.frame = shadowView?.bounds ?? .zero
        shadowView?.addSubview(presentedViewControllerView)
        
        //更新背景蒙层
        dimmingView.backgroundColor = dimmingColor
        containerView?.addSubview(dimmingView)
        dimmingView.alpha = 0
        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { context in
            self.dimmingView.alpha = max(0, self.dimmingAlpha)
        }, completion: nil)
    }
    
    /// present过渡结束
    override func presentationTransitionDidEnd(_ completed: Bool) {
        //在取消交互动画，动画未完成的情况下可能为NO，即present中断，则重置为初始态
        //(如transitionContext.completeTransition方法传NO)
        if completed == false {
            dimmingView.removeFromSuperview()
            shadowView = nil
        }
    }
    
    /// 即将开始dismiss过渡
    override func dismissalTransitionWillBegin() {
        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { context in
            self.dimmingView.alpha = 0
        }, completion: nil)
    }
    
    /// dismiss过渡结束
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        //判断dismiss是否完整结束，如果被打断未完成，则代表dismiss中断，则不应该重置为初始态
        if completed {
            dimmingView.removeFromSuperview()
            shadowView = nil
        }
    }
    
    /// 过渡后的VC-preferredContentSize改变
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        if container === presentedViewController {
            containerView?.setNeedsLayout()
        }
    }
    
    /// 内容所需宽高尺寸
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if container === presentedViewController {
            return container.preferredContentSize
        } else {
            return super.size(forChildContentContainer: container, withParentContainerSize: parentSize)
        }
    }
    
    /// containerView即将开始布局子视图
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        dimmingView.frame = containerView?.bounds ?? .zero
        shadowView?.frame = frameOfPresentedViewInContainerView
    }
}

//MARK: - present/dismiss过渡配置
extension CDPAlertPresentationController: UIViewControllerTransitioningDelegate {
    /// 设置过渡处理类
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return self
    }
    
    /// 设置present动画处理类
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    /// 设置dismiss动画处理类
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}

//MARK: - 动画
extension CDPAlertPresentationController: UIViewControllerAnimatedTransitioning {
    /// 动画时长
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        //判断是否需要动画
        return transitionContext?.isAnimated ?? false ? max(0, duration) : 0
    }
    
    /// 动画处理
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //获取present前后对应VC
        guard let fromVC = transitionContext.viewController(forKey: .from), let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        //fromVC.view当前的frame（present前）暂不使用
        //var fromViewInitFrame = transitionContext.initialFrame(for: fromVC)
        //fromVC.view在present后的frame
        var fromViewFinalFrame = transitionContext.finalFrame(for: fromVC)
        //toVC.view当前的frame（present前）
        var toViewInitFrame = transitionContext.initialFrame(for: toVC)
        //toVC.view在present后的frame
        let toViewFinalFrame = transitionContext.finalFrame(for: toVC)
        
        //获取present前后对应的view
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        
        //获取containerView
        let containerView = transitionContext.containerView
        //添加最终present后的view
        if let view = toView {
            containerView.addSubview(view)
        }
        
        //是否正在present
        let isPresenting = (fromVC === presentingViewController)
        //进行回调
        willBeginTransition?(isPresenting)
        
        if isPresenting {
            //正在present
            toViewInitFrame.size = toViewFinalFrame.size
            
            //判断出现方式
            let initX: CGFloat = (containerView.bounds.maxX - toViewFinalFrame.size.width) / 2.0
            switch presentType {
            case .bottom:
                //从底部出现
                toViewInitFrame.origin = CGPoint(x: initX, y: containerView.bounds.maxY)
            case .top:
                //从顶部出现
                toViewInitFrame.origin = CGPoint(x: initX, y: containerView.bounds.minY - toViewFinalFrame.size.height)
            case .zoom, .zoomAlpha:
                //屏幕中间缩放
                let zoomX = toViewFinalFrame.minX + toViewFinalFrame.width / 2.0
                let zoomY = toViewFinalFrame.minY + toViewFinalFrame.height / 2.0
                toViewInitFrame = CGRect(x: zoomX, y: zoomY, width: 0, height: 0)
            case .nothing:
                //直接出现
                toViewInitFrame.origin = toViewFinalFrame.origin
            }
            
            toView?.frame = toViewInitFrame
        } else {
            //正在dismiss
            //直接用fromView.frame而不用fromViewInitFrame，是因为在外包了一层阴影view，虽最终取值差不多相同，但逻辑上用此更准确合理)
            //判断消失方式
            switch dismissType {
            case .bottom:
                //往底部消失
                fromViewFinalFrame = fromView?.frame.offsetBy(dx: 0, dy: fromView?.frame.maxY ?? 0) ?? .zero
            case .top:
                //往顶部消失
                fromViewFinalFrame = fromView?.frame.offsetBy(dx: 0, dy: -(fromView?.frame.maxY ?? 0)) ?? .zero
            case .zoom, .zoomAlpha:
                //屏幕中间缩放
                let zoomOriFrame = fromView?.frame ?? .zero
                let zoomX = zoomOriFrame.minX + zoomOriFrame.width / 2.0
                let zoomY = zoomOriFrame.minY + zoomOriFrame.height / 2.0
                fromViewFinalFrame = CGRect(x: zoomX, y: zoomY, width: 0, height: 0)
            case .nothing:
                //直接消失 (最终位置与bottom一样，只是无动画过度)
                fromViewFinalFrame = fromView?.frame.offsetBy(dx: 0, dy: fromView?.frame.maxY ?? 0) ?? .zero
            }
        }
        
        //判断是否需要动画过度
        if (isPresenting && presentType == .nothing) ||
            (!isPresenting && dismissType == .nothing) {
            //不需要动画过度
            if isPresenting {
                toView?.frame = toViewFinalFrame
            } else {
                fromView?.frame = fromViewFinalFrame
            }
            //是否被取消
            let wasCancelled = transitionContext.transitionWasCancelled
            //通知系统动画是否完整结束
            transitionContext.completeTransition(!wasCancelled)
        } else {
            //需要动画过度
            //获取动画时长
            let transitionDuration = transitionDuration(using: transitionContext)
            //透明度
            toView?.alpha = (isPresenting && presentType == .zoomAlpha) ? 0 : 1
            fromView?.alpha = 1
            //执行present/dismiss动画
            UIView.animate(withDuration: transitionDuration) {
                if isPresenting {
                    toView?.frame = toViewFinalFrame
                    toView?.alpha = 1
                } else {
                    fromView?.frame = fromViewFinalFrame
                    fromView?.alpha = (self.dismissType == .zoomAlpha) ? 0 : 1
                }
            } completion: { finished in
                //是否被取消
                let wasCancelled = transitionContext.transitionWasCancelled
                //通知系统动画是否完整结束
                transitionContext.completeTransition(!wasCancelled)
            }
        }
    }
}

//MARK: - 点击事件
private extension CDPAlertPresentationController {
    /// 背景蒙层点击
    @objc func dimmingClick() {
        if dimmingCanClickDisappear {
            //回调
            dimmingClickBeforeDisappear?()
            //退出弹层
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
}
