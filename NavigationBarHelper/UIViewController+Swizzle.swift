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
    
    @objc func jw_swizzling_UIViewController_viewWillLayoutSubViews() {
        jw_swizzling_UIViewController_viewWillLayoutSubViews()
        jw_viewWillLayoutSubViews()
    }
    
    @available(iOS 11.0, *)
    @objc func jw_swizzling_UIViewController_viewSafeAreaInsetsDidChange() {
        jw_viewSafeAreaInsetsDidChange()
        jw_swizzling_UIViewController_viewSafeAreaInsetsDidChange()
    }
    
    @objc func jw_swizzling_UIViewController_viewWillAppear(_ animated: Bool) {
        jw_viewWillAppear(animated)
        jw_swizzling_UIViewController_viewWillAppear(animated)
    }
    
    @objc func jw_swizzling_UIViewController_viewDidAppear(_ animated: Bool) {
        jw_viewDidAppear(animated)
        jw_swizzling_UIViewController_viewDidAppear(animated)
    }
    
    @objc func jw_swizzling_UIViewController_viewWillDisappear(_ animated: Bool) {
        jw_viewWillDisappear(animated)
        jw_swizzling_UIViewController_viewWillDisappear(animated)
    }
    
    private func jw_viewWillLayoutSubViews() {
        getStoredNavigationBarHelper()?.setNeedsLayout()
    }
    
    @available(iOS 11.0, *)
    private func jw_viewSafeAreaInsetsDidChange() {
        getStoredNavigationBarHelper()?.setNeedsLayout()
    }
    
    private func jw_viewWillAppear(_ animated: Bool) {
        guard getStoredNavigationBarHelper() != nil else {
            return
        }
        if case .followPage = NavigationBarHelper.transitionStyle {
            if !navigationBarHelper.isNavigationRegionSnapshotted {
                synchronizeForegroundAttr()
            }
            navigationController?.setNavigationBarHidden(false, animated: true)
        } else {
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
                    UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration), animations: {
                        self.synchronizeForegroundAttr()
                        if let bar = self.navigationController?.navigationBar {
                            self.navigationBarHelper.fixNavigationTitleView(for: bar)
                        }
                    })
                }
            } else {//perform with no animation
                synchronizeForegroundAttr()
            }
        }
    }
    
    private func jw_viewDidAppear(_ animated: Bool) {
        guard getStoredNavigationBarHelper() != nil else {
            return
        }
        if case .followPage = NavigationBarHelper.transitionStyle {
            navigationBarHelper.removeNavigationRegionSnapshot()
            navigationBarHelper.restoreClearedForegroundAttr()
            synchronizeForegroundAttr()
        }
    }
    
    private func jw_viewWillDisappear(_ animated: Bool) {
        guard getStoredNavigationBarHelper() != nil else {
            return
        }
        if case .followPage = NavigationBarHelper.transitionStyle {
            navigationBarHelper.snapshotNavigationRegion()
            navigationBarHelper.clearForegroundAttr(isRestoreEnabled: true)
            navigationController?.setNavigationBarHidden(true, animated: false)
        }

    }
    
    private func synchronizeForegroundAttr() {
        navigationBarHelper.synchronizeForegroundAttr()
    }
    
}
