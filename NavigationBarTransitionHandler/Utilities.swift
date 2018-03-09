//
// Utilities.swift
//
// Copyright (c) 2015 Jerry Wong
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

extension UIViewController {
    
    typealias NavigationBarBackgroundAttr = (backgroundImages: [UIBarMetrics: UIImage], shadowImage: UIImage?, barTintColor: UIColor?, isTranslucent: Bool)
    
    typealias NavigationBarForegroundAttr = (tintColor: UIColor?, barStyle: UIBarStyle, titleAttributes: [NSAttributedStringKey: Any]?)
    
    func stashBackgroundAttr(forNavigationBar bar: UINavigationBar) {
        var backgroundImages = [UIBarMetrics: UIImage]()
        [UIBarMetrics.default, UIBarMetrics.compact, UIBarMetrics.defaultPrompt, UIBarMetrics.compactPrompt].forEach {
            guard let img = bar.backgroundImage(for: $0) else {
                return
            }
            backgroundImages[$0] = img
        }
        
        let attr: NavigationBarBackgroundAttr = (backgroundImages, bar.shadowImage, bar.barTintColor, bar.isTranslucent)
        objc_setAssociatedObject(self, &BarBackgroundStashedInfoKey, attr, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func restoreBackgroundAttr(forNavigationBar bar: UINavigationBar) {
        guard let vcs = navigationController?.viewControllers, vcs.count >= 2,
              let bar = navigationController?.navigationBar,
              let attr = objc_getAssociatedObject(vcs[vcs.count - 2], &BarBackgroundStashedInfoKey) as? NavigationBarBackgroundAttr else {
            return
        }
        if attr.backgroundImages.count > 0 {
            attr.backgroundImages.forEach { bar.setBackgroundImage($0.1, for: $0.0) }
        } else {
            [.default, .compact, .defaultPrompt, .compactPrompt].forEach { bar.setBackgroundImage(nil, for: $0) }
        }
        
        bar.shadowImage = attr.shadowImage
        bar.isTranslucent = attr.isTranslucent
        bar.barTintColor = attr.barTintColor
    }
    
    func stashForegroundAttr(forNavigationBar bar: UINavigationBar) {
        let attr: NavigationBarForegroundAttr = (bar.tintColor, bar.barStyle, bar.titleTextAttributes)
        objc_setAssociatedObject(self, &BarForegroundStashedInfoKey, attr, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func restoreForegroundAttr(forNavigationBar bar: UINavigationBar) {
        guard let bar = navigationController?.navigationBar,
            let attr = objc_getAssociatedObject(self, &BarForegroundStashedInfoKey) as? NavigationBarForegroundAttr else {
                return
        }
        
        bar.tintColor = attr.tintColor
        bar.titleTextAttributes = attr.titleAttributes
        bar.barStyle = attr.barStyle
    }
}

extension UIViewController {
    
    open var barBackgroundHelper: NavigationBarBackgroundHelper {
        
        get {
            var handler = getStoredBarBackgroundHelper()
            if handler == nil {
                handler = NavigationBarBackgroundHelper(viewController: self)
                self.barBackgroundHelper = handler!
            }
            return handler!
        }
        
        set {
            objc_setAssociatedObject(self, &BarHelperKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
    }
    
    fileprivate func getStoredBarBackgroundHelper() -> NavigationBarBackgroundHelper? {
        return objc_getAssociatedObject(self, &BarHelperKey) as? NavigationBarBackgroundHelper
    }
}

extension UIViewController {
    
    @available(iOS 11.0, *)
    @objc func jw_viewSafeAreaInsetsDidChange() {
        jw_viewSafeAreaInsetsDidChange()
        barBackgroundHelper.setNeedsLayout()
    }
    
    @objc func jw_viewWillAppear(_ animated: Bool) {
        if animated {
            if transitionCoordinator?.isCancelled ?? false {
                UIView.animate(withDuration: CATransaction.animationDuration(), animations: {
                    self.synchronizeForegroundAttr()
                })
            } else {
                transitionCoordinator?.animateAlongsideTransition(in: transitionCoordinator?.containerView.window, animation: { (ctx) in
                    self.synchronizeForegroundAttr()
                }, completion: nil)
            }
        } else {
            synchronizeForegroundAttr()
        }
        jw_viewWillAppear(animated)
    }
    
    private func synchronizeForegroundAttr() {
        barBackgroundHelper.synchronizeForegroundAttr()
    }
    
}

extension UIImage {
    
    convenience init?(color: UIColor, size: CGSize? = CGSize(width: 1.0, height: 1.0)) {
        let rect = CGRect(origin: CGPoint.zero, size: size ?? CGSize(width: 1.0, height: 1.0))
        
        UIGraphicsBeginImageContext(rect.size)
        defer {
            UIGraphicsEndImageContext()
        }
        
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(color.cgColor)
        ctx?.fill(rect)
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}

extension NSObject {
    
    class func exchange(_ oldSEL: Selector, withSEL newSEL: Selector) throws {
        
        guard let originMethod = class_getInstanceMethod(self, oldSEL),
            let altMethod = class_getInstanceMethod(self, newSEL) else {
                throw NSError(domain: "com.jerry", code: 0, userInfo: [NSLocalizedDescriptionKey: "cannot find methods for SEL \(oldSEL) or \(newSEL)"])
        }
        
        let didAddMethod = class_addMethod(self, oldSEL, method_getImplementation(altMethod), method_getTypeEncoding(altMethod))
        if didAddMethod {
            class_replaceMethod(self, newSEL, method_getImplementation(originMethod), method_getTypeEncoding(originMethod))
        } else {
            method_exchangeImplementations(originMethod, altMethod)
        }
    }
}

private var BarHelperKey: Void?

private var BarBackgroundStashedInfoKey: Void?

private var BarForegroundStashedInfoKey: Void?
