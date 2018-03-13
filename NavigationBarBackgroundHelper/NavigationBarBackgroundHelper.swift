//
// NavigationBarBackgroundHelper.swift
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

@objc public protocol NavigationBarBackgroundHelperDelegate {
    
    /// Called before the mirror view capturing the bar's background attribute.
    /// It is the best time for you to do additional change to the bar's background attr.
    /// After this function is called, the mirror background view will synchronize with the bar's background.
    @objc optional func navigationBarBackgroundAttrDidRestore()
    
    /// Called after the navigation bar's foreground attribute being restored, especially when the viewController's appearing.
    /// Do additional change if you have modified the navigation bar.(e.g, you have set the bar tint color according to scrollview offset)
    @objc optional func navigationBarForegroundAttrDidRestore()
    
}

open class NavigationBarBackgroundHelper {
    
    open private(set) var view: NavigationBarBackgroundView?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    open func performNavigationBarUpdates(_ action: (() -> ())?) {
        beginUpdate()
        action?()
        endUpdate()
    }
    
    open func setNeedsLayout() {
        guard let vc = viewController else {
            return
        }
        let insetsTop = vc.view.safeAreaInsets.top
        view?.frame = CGRect(x: 0, y: 0 + (view?.transform.ty ?? 0), width: view?.frame.size.width ?? 0, height: insetsTop)
    }
    
    open func synchronizeForegroundAttr() {
        guard let bar = viewController?.navigationController?.navigationBar else {
            return
        }
        viewController?.restoreForegroundAttr(forNavigationBar: bar)
    }
    
    private weak var viewController: UIViewController?
    
    private var keyPathObservations: [NSKeyValueObservation]?
    
}

extension NavigationBarBackgroundHelper {
    
    open class func load() {
        _ = __init__
    }
    
}

extension NavigationBarBackgroundHelper {
    
    private func beginUpdate() {
        guard let vc = viewController, let bar = vc.navigationController?.navigationBar else {
            return
        }
        vc.restoreBackgroundAttr(forNavigationBar: bar)
    }
    
    private func endUpdate() {
        guard let ctx = viewController else {
            return
        }
        let containerView = ctx.view
        guard let bar = ctx.navigationController?.navigationBar else {
            return
        }
        if view == nil {
            view = NavigationBarBackgroundView(navigationBar: bar)
            view?.autoresizingMask = [.flexibleWidth]
        } else {
            view?.update(withNavigationBar: bar)
        }
        containerView?.addSubview(view!)
        
        if let scrollView = containerView as? UIScrollView {
            keyPathObservations = [
                scrollView.observe(\.contentOffset, options: .new, changeHandler: { [weak self] (scrollView, change) in
                    self?.view?.transform = CGAffineTransform(translationX: 0, y: change.newValue?.y ?? 0)
                })
            ]
        }
        
        reset()
    }
    
    private func reset() {
        guard let bar = viewController?.navigationController?.navigationBar else {
            return
        }
        viewController?.stashForegroundAttr(forNavigationBar: bar)
        viewController?.stashBackgroundAttr(forNavigationBar: bar)
        [.default, .compact, .defaultPrompt, .compactPrompt].forEach{ bar.setBackgroundImage(TransparentImage, for: $0) }
        bar.shadowImage = TransparentImage
        bar.isTranslucent = true
    }
    
}

let TransparentImage = UIImage(color: UIColor.clear)

fileprivate let __init__: Bool = {
    do {
        if #available(iOS 11.0, *) {
            try UIViewController.exchange(#selector(UIViewController.viewSafeAreaInsetsDidChange), withSEL: #selector(UIViewController.jw_viewSafeAreaInsetsDidChange))
        } else {
            throw NSError(domain: "com.jerry", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unsupported yet"])
        }
        try UIViewController.exchange(#selector(UIViewController.viewWillAppear(_:)), withSEL: #selector(UIViewController.jw_viewWillAppear(_:)))
    } catch {
        debugPrint(error)
        print()
    }
    return true
}()
