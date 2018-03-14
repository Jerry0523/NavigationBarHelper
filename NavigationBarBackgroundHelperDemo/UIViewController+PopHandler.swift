//
//  UIViewController+PopHandler.swift
//  JWKit
//
//  Created by Jerry on 2017/11/2.
//  Copyright © 2017年 com.jerry. All rights reserved.
//

import UIKit

public protocol PopHandler {
    
    var shouldPop: Bool { get }
    
}

extension UINavigationController : UINavigationBarDelegate {
    
    @objc func jw_viewDidLoad() {
        jw_viewDidLoad()
        
        objc_setAssociatedObject(self, &UINavigationController.originDelegateKey, interactivePopGestureRecognizer?.delegate, .OBJC_ASSOCIATION_ASSIGN)
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if viewControllers.count < navigationBar.items?.count ?? 0 {
            return true
        }
        var shouldPop = true
        if let vc = topViewController as? PopHandler {
            shouldPop = vc.shouldPop
        }
        
        if shouldPop {
            DispatchQueue.main.async {
                self.popViewController(animated: true)
            }
        } else {
            for subView in navigationBar.subviews {
                if 0 < subView.alpha && subView.alpha < 1 {
                    UIView.animate(withDuration: 0.25, animations: {
                        subView.alpha = 1.0
                    })
                }
            }
        }
        return shouldPop
    }
    
    private static var originDelegateKey: Void?
}

extension UINavigationController : UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == interactivePopGestureRecognizer {
            if viewControllers.count <= 1 {
                return false
            }
            
            if let vc = topViewController as? PopHandler {
                return vc.shouldPop
            }
            
            let originDelegate = objc_getAssociatedObject(self, &UINavigationController.originDelegateKey) as? UIGestureRecognizerDelegate
            return originDelegate?.gestureRecognizerShouldBegin?(gestureRecognizer) ?? true
        }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == interactivePopGestureRecognizer {
            return true
        }
        return false
    }
}
