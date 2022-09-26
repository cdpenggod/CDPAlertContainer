# CDPAlertContainer
## An alert container that enables your custom view to pop off the screen with any effect.
## Alert弹层容器，可使你的 自定义view 自动拥有 以任意效果 从屏幕弹出的 弹层能力，且支持各种自定义设置，如 弹入/弹出效果自定义，背景蒙层自定义，弹层圆角，弹层阴影 等等。
## 详情看 demo 演示。

## other see: https://github.com/cdpenggod/CDPPopupContainer

```swift
//吊起弹层 (其中一种appear类方法，根据自己需求选择对应的appear方法)
CDPAlertContainer.appear(contentView: customView, fromVC: self) { container in
    container.alertHeight = 400 //弹层总高度
    container.alertMargin = 20 //弹层两侧距离屏幕距离
    container.cornerRadius = 15 //弹层圆角
    container.dimmingColor = .red //背景蒙层颜色
    container.dimmingAlpha = 0.7 //背景蒙层透明度
    container.haveShadow = true //弹层是否带阴影
    container.dimmingCanClickDisappear = false //背景蒙层是否可点击退出弹层
    
    //如果想修改出现与消失的动画方式，可通过 delegate方法 或 直接修改type属性
    //delegate优先级 高于 直接修改type属性
    container.delegate = self //代理
    container.presentType = .nothing //弹层出现效果
    container.dismissType = .zoomAlpha //弹层消失效果
    
    //仅列出部分可配置参数，其他自定义参数具体查看 CDPAlertContainer.swift
    
    //如果需要用Autolayout布局 或 不想弹层吊起前设置frame，可在此回调里对内容view进行布局
    //此时内容view已被添加进容器，父view为container.view
 } completion: nil
```
