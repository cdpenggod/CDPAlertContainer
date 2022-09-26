//
//  ViewController.swift
//  alertTest
//
//  Created by chaidongpeng on 2022/9/26.
//

import UIKit

class ViewController: UIViewController {
    /// 宽度
    let customWidth: CGFloat = UIScreen.main.bounds.width - 140
    
    /// 随便自定义的内嵌UIView,位置根据frame自定义,可以填充满弹层，也可以留有边距
    private lazy var customView: UIView = {
        let view = UIView(frame: CGRect(x: 30, y: 20, width: customWidth, height: 200))
        view.backgroundColor = .red
        view.addSubview(label)
        return view
    }()
    private lazy var label: UILabel = {
        let label = UILabel(frame: CGRect(x: 10, y: 10, width: customWidth - 20, height: 180))
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addButton(frame: CGRect(x: 30, y: 80, width: customWidth, height: 30), title: "吊起弹层", action: #selector(buttonClick1))
                
        addButton(frame: CGRect(x: 30, y: 120, width: customWidth, height: 30), title: "弹层-改变弹层高度", action: #selector(buttonClick2))
        
        addButton(frame: CGRect(x: 30, y: 160, width: customWidth, height: 30), title: "弹层-部分参数自定义", action: #selector(buttonClick3))
    }
    
    /// 添加button
    /// - Parameters:
    ///   - frame: 布局
    ///   - title: title
    ///   - action: 执行方法
    func addButton(frame: CGRect, title: String, action: Selector) {
        let button = UIButton(frame: frame)
        button.adjustsImageWhenHighlighted = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.addTarget(self, action: action, for: .touchUpInside)
        view.addSubview(button)
    }
}

//MARK: - CDPAlertContainerDelegate 弹层容器代理
extension ViewController: CDPAlertContainerDelegate {
    /// 点击背景蒙层回调
    func alertContainerDidClickDimming(container: CDPAlertContainer) {
        print("点击了背景蒙层")
    }
    
    /// 返回 弹层出现方式 (优先级高于 .presentType 属性，会同步修改该属性)
    func alertContainerPresentType(container: CDPAlertContainer) -> CDPAlertPresentType {
        return .top
    }
    
    /// 返回 弹层消失方式 (优先级高于 .dismissType 属性，会同步修改该属性)
    func alertContainerDismissType(container: CDPAlertContainer) -> CDPAlertDismissType {
        return .bottom
    }
}

//MARK: - 点击事件
private extension ViewController {
    /// 按钮1点击
    @objc private func buttonClick1() {
        label.text = "红色为自定义内嵌UIView\n\n位置根据frame自定义,可以填充满弹层，也可以留有边距"
        //吊起弹层
        CDPAlertContainer.appear(contentView: customView, fromVC: self)
    }
    
    /// 按钮2点击
    @objc private func buttonClick2() {
        customView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 80, height: 260)
        label.text = "红色为自定义内嵌UIView\n\n内嵌view.frame调整为与弹层一样，且弹层高度调整为260"
        //吊起弹层
        CDPAlertContainer.appear(contentView: customView, fromVC: self, alertHeight: 260)
    }
    
    /// 按钮3点击
    @objc private func buttonClick3() {
        customView.frame = CGRect(x: 30, y: 20, width: customWidth, height: 300)
        label.frame = CGRect(x: 10, y: 10, width: customWidth - 20, height: 280)
        label.text = "红色为自定义内嵌UIView\n\n弹层高度调整为 350，弹层圆角 15，背景蒙层变色为 .red，背景蒙层透明度变为 0.7，点击背景蒙层不消失，外层开启阴影，阴影可根据参数自定义,弹层距屏幕两边 20\n\n其他自定义参数see CDPAlertContainer.swift"
        //吊起弹层
        //(如果不想用frame，需要用Autolayout布局，可在config回调里进行)
        CDPAlertContainer.appear(contentView: customView, fromVC: self) { container in
            container.alertHeight = 350
            container.alertMargin = 20
            container.cornerRadius = 15
            container.dimmingColor = .red
            container.dimmingAlpha = 0.7
            container.haveShadow = true
            container.dimmingCanClickDisappear = false
            
            //如果想修改出现与消失的动画方式，可通过 delegate方法 或 直接修改type属性
            //delegate优先级 高于 直接修改type属性
            container.delegate = self
            container.presentType = .nothing
            container.dismissType = .zoomAlpha
            
            //如果需要用Autolayout布局，可在此回调里对contentView与container.view进行布局
        } completion: {
            print("弹层吊起完成回调,3s后自动消失")
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                CDPAlertContainer.disappear(animated: true, completion: nil)
            }
        }
    }
    
}
