//
// UIViewController+Swizzle.swift
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
    
    @available(iOS 11.0, *)
    @objc func jw_viewSafeAreaInsetsDidChange() {
        getStoredBarBackgroundHelper()?.setNeedsLayout()
        jw_viewSafeAreaInsetsDidChange()
    }
    
    @objc func jw_viewWillAppear(_ animated: Bool) {
        if getStoredBarBackgroundHelper() != nil {
            if animated {
                if transitionCoordinator?.isInteractive ?? false {//interactive pop back gesture
                    if transitionCoordinator?.isCancelled ?? false {//gesture cancelled, fromVc reappeared
                        synchronizeForegroundAttr()
                    } else {//gesture ongoing, toVc execute animation
                        transitionCoordinator?.animate(alongsideTransition: { (ctx) in
                            self.synchronizeForegroundAttr()
                        }, completion: { (ctx) in
                            
                        })
                    }
                } else {//non-interactive pop back (click the back item)
                    UIView.animate(withDuration: TimeInterval(UINavigationControllerHideShowBarDuration), animations: {
                        self.synchronizeForegroundAttr()
                    })
                }
            } else {//perform with no animation
                synchronizeForegroundAttr()
            }
        }
        jw_viewWillAppear(animated)
    }
    
    private func synchronizeForegroundAttr() {
        barBackgroundHelper.synchronizeForegroundAttr()
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
