//
//  ProgressHUD.swift
//  weixiaoyuan
//
//  Created by listen on 2018/3/1.
//  Copyright © 2018年 USI Technology (Shenzhen) Company Limited. All rights reserved.
//

import UIKit

// 加载动画ImageView的Rect
private let ProgressHUDActivityImageViewRect         = CGRect(x: 0.0, y: 0.0, width: 64.0, height: 64.0)

// 文字提示字体
private let ProgressHUDTextPromptTextFont            = UIFont(name: "Arial", size: 16)

// 文字提示背景颜色
private let ProgressHUDTextPromptBackgroundColor     = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.75)

/// 自定义HUD(HUD，Head Up Display 平视显示器?)
class ProgressHUD: UIView {
    
    fileprivate var activityImageView : UIImageView!
    fileprivate var imageArray        : Array<UIImage>!
    fileprivate var toastButton       : UIButton!
    fileprivate var duration          : TimeInterval!
    
    
    // MARK: - super methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        initData()
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - private methods
    // 初始化数据
    fileprivate func initData() {
        if imageArray == nil {
            imageArray = Array<UIImage>()
            for i in 1...36 {
                let image = UIImage(named: String(format: "img_loading%d", arguments: [i]))
                imageArray.append(image!)
            }
        }
    }
    
    // 初始化界面
    fileprivate func initUI() {
        if activityImageView == nil {
            activityImageView = UIImageView(frame: ProgressHUDActivityImageViewRect)
            activityImageView.animationImages = imageArray
            activityImageView.animationDuration = 0
            activityImageView.animationRepeatCount = 0
        }
        self.backgroundColor = UIColor.clear
    }
    
    // 绑定加载动画视图imageView
    fileprivate func bindActivityImageView() {
        self.addSubview(activityImageView)
        activityImageView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: activityImageView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: activityImageView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0.0))
        activityImageView.addConstraint(NSLayoutConstraint(item: activityImageView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1.0, constant: ProgressHUDActivityImageViewRect.width))
        activityImageView.addConstraint(NSLayoutConstraint(item: activityImageView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1.0, constant: ProgressHUDActivityImageViewRect.height))
    }
    
    // 开始加载动画
    fileprivate func startActivity() {
        self.bringSubviewToFront(activityImageView)
        activityImageView.startAnimating()
    }
    
    // 初始化提示
    fileprivate func initTextPrompt(_ text:String, duration:TimeInterval) {
        self.duration = duration
        let textLabel               = UILabel(frame: CGRect.zero)
        textLabel.frame.size.width  = Screen_Width-48
        textLabel.backgroundColor   = UIColor.clear
        textLabel.textColor         = UIColor.white
        textLabel.textAlignment     = NSTextAlignment.center
        textLabel.font              = ProgressHUDTextPromptTextFont
        textLabel.text              = text
        textLabel.numberOfLines     = 0
        textLabel.sizeToFit()
        
        toastButton = UIButton(frame: CGRect(x: 0, y: 0, width: textLabel.frame.width+10, height: textLabel.frame.height+8))
        toastButton.layer.cornerRadius  = 5.0
        toastButton.layer.borderWidth   = 1.0
        toastButton.layer.borderColor   = UIColor.gray.withAlphaComponent(0.5).cgColor
        toastButton.backgroundColor     = ProgressHUDTextPromptBackgroundColor
        toastButton.addSubview(textLabel)
        toastButton.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
        toastButton.alpha = 0.0
        
        textLabel.frame = CGRect(x: (toastButton.frame.width - textLabel.frame.width)/2, y: (toastButton.frame.height - textLabel.frame.height)/2, width: textLabel.frame.width, height: textLabel.frame.height)
        
        let window = UIApplication.shared.keyWindow
        toastButton.center = CGPoint(x: window!.center.x, y: window!.center.y)
        window!.addSubview(toastButton)
    }
    
    // 移除提示
    fileprivate func dismissPrompt() {
        toastButton.removeFromSuperview()
        toastButton = nil
    }
    
    // 渐显提示动画
    fileprivate func showPromptAnimation() {
        UIView.animate(withDuration: self.duration, animations: { () -> Void in
            self.toastButton.alpha = 1.0
        }, completion: { (completion) -> Void in
            //if completion {
            self.hidePromptAnimation()
            // }
        })
    }
    
    //渐消提示动画
    fileprivate func hidePromptAnimation() {
        UIView.animate(withDuration: self.duration, animations: { () -> Void in
            self.toastButton.alpha = 0.0
        }, completion: { (completion) -> Void in
            //if completion {
            self.dismissPrompt()
            //}
        })
    }
    
    // MARK: - class methods
    // 在ViewController上显示加载数据动画
    class func showLoadingAnimationAtViewController(_ controller:UIViewController!, animated:Bool, isUserInteractionEnabled:Bool = true) {
        showLoadingAnimationAtView(controller.view, animated: animated, isUserInteractionEnabled:isUserInteractionEnabled)
    }
    
    // 在View上显示加载数据动画
    class func showLoadingAnimationAtView(_ view:UIView!, animated:Bool, topDistance:CGFloat = 64.0, isUserInteractionEnabled:Bool = true) {
        showLoadingAnimationAtView(view, backgroundColor: UIColor.clear, animated: animated, topDistance:topDistance, isUserInteractionEnabled:isUserInteractionEnabled)
    }
    
    // 在View上显示加载数据动画
    class func showLoadingAnimationAtView(_ view:UIView!, backgroundColor:UIColor!, animated:Bool, topDistance:CGFloat, isUserInteractionEnabled:Bool) {
        showLoadingAnimationAtView(view, backgroundColor: backgroundColor, topDistance: topDistance, animated: animated, isUserInteractionEnabled:isUserInteractionEnabled)
    }
    
    // 在View上显示加载数据动画
    class func showLoadingAnimationAtView(_ view:UIView!, backgroundColor:UIColor!, topDistance:CGFloat, animated:Bool, isUserInteractionEnabled:Bool) {
        
        var hud:ProgressHUD?
        
        for subview in view.subviews {
            if subview.isKind(of: ProgressHUD.self) {
                hud = subview as? ProgressHUD
                break
            }
        }
        
        if hud == nil {
            hud = ProgressHUD(frame: CGRect.zero)
            hud!.backgroundColor = backgroundColor
            view.addSubview(hud!)
            
            hud!.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraint(NSLayoutConstraint(item: hud!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: topDistance))
            view.addConstraint(NSLayoutConstraint(item: hud!, attribute: NSLayoutConstraint.Attribute.left, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.left, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: hud!, attribute: NSLayoutConstraint.Attribute.right, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.right, multiplier: 1.0, constant: 0.0))
            view.addConstraint(NSLayoutConstraint(item: hud!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0.0))
            hud!.bindActivityImageView()
        }
        hud!.isUserInteractionEnabled = isUserInteractionEnabled
        view.bringSubviewToFront(hud!)
        hud!.startActivity()
    }
    
    // 在ViewController上隐藏加载数据动画
    class func hideLoadingAnimationAtViewController(_ controller:UIViewController!, animated:Bool) {
        hideLoadingAnimationAtView(controller.view, animated: animated)
    }
    
    // 在View上隐藏加载数据动画
    class func hideLoadingAnimationAtView(_ view:UIView!, animated:Bool) {
        
        for subview in view.subviews {
            if subview.isKind(of: ProgressHUD.self) {
                subview.removeFromSuperview()
                break
            }
        }
    }
    
    // 在屏幕上显示文字提示
    class func showTextPrompt(_ text:String, duration:TimeInterval = 1.0) {
        let hud = ProgressHUD()
        hud.initTextPrompt(text, duration: duration)
        hud.showPromptAnimation()
    }
    
    // 在屏幕上显示文字提示
    class func showTextPrompt(_ text:String, duration:TimeInterval = 1.0, success: @escaping () -> Void) {
        let hud = ProgressHUD()
        hud.initTextPrompt(text, duration: duration)
        
        UIView.animate(withDuration: hud.duration, animations: { () -> Void in
            hud.toastButton.alpha = 1.0
        }, completion: { (completion) -> Void in
            if completion {
                hud.hidePromptAnimation()
                success()
            }
        })
    }
}
