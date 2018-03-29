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
    
    var previousBarBackgroundHelper: NavigationBarBackgroundHelper? {
        get {
            guard let vcs = navigationController?.viewControllers, vcs.count >= 2 else {
                return nil
            }
            return vcs[vcs.count - 2].getStoredBarBackgroundHelper()
        }
    }
    
    func getStoredBarBackgroundHelper() -> NavigationBarBackgroundHelper? {
        return objc_getAssociatedObject(self, &BarHelperKey) as? NavigationBarBackgroundHelper
    }
    
}

@objc public protocol NavigationBarBackgroundHelperDelegate {
    
    /// Return true if you want to restore the bar foreground attribute manually. Otherwise, the library will do it automatically.
    /// If you have changed the bar foreground attr manually (e.g., change the barTintColor by scrollView scrolling), you should override this function and return true to take over the bar foreground attr restoration.
    @objc optional func takeOverNavigationBarForegroundAttrRestoration() -> Bool
    
    /// Called before the mirror view capturing the bar's background attribute.
    /// It is the best time for you to do additional change to the bar's background attr.
    /// After this function is called, the mirror background view will synchronize with the bar's background.
    @objc optional func navigationBarBackgroundAttrDidRestore()
    
    /// Called after the navigation bar's foreground attribute being restored, especially when the viewController's appearing.
    /// Do additional change if you have modified the navigation bar out of the performNavigationBarUpdates scope.(e.g, you have set the bar tint color according to scrollview offset)
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
        let insetsTop = max(vc.view.safeAreaInsets.top, vc.navigationController?.navigationBar.frame.size.height ?? 0)
        view?.frame = CGRect(x: 0, y: 0 + (view?.transform.ty ?? 0), width: view?.frame.size.width ?? 0, height: insetsTop)
    }
    
    open func synchronizeForegroundAttr() {
        guard let nc = viewController?.navigationController else {
            return
        }
        let bar = nc.navigationBar
        restoreForegroundAttr(forNavigationBar: bar)
        
        view?.isHidden = isNavigationBarHidden
        if nc.isNavigationBarHidden != isNavigationBarHidden {
            nc.setNavigationBarHidden(isNavigationBarHidden, animated: true)
        }
    }
    
    var backgroundAttr: NavigationBarBackgroundAttr?
    
    var foregroundAttr: NavigationBarForegroundAttr?
    
    var isNavigationBarHidden = false
    
    weak var viewController: UIViewController?
    
    var keyPathObservations: [NSKeyValueObservation]?
    
}

extension NavigationBarBackgroundHelper {
    
    open class func load() {
        _ = __init__
    }
    
}

extension NavigationBarBackgroundHelper {
    
    private func beginUpdate() {
        
        guard
            let bar = viewController?.navigationController?.navigationBar,
            let previousHelper = viewController?.previousBarBackgroundHelper else {
                return
        }
        
        previousHelper.restoreBackgroundAttr(forNavigationBar: bar)
        //we show the nc's bar by default. It is your job to call setNavigationBarHidden within the performNavigationBarUpdates scope.
        viewController?.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func endUpdate() {
        guard let ctx = viewController else {
            return
        }
        
        let containerView = ctx.view
        guard let bar = ctx.navigationController?.navigationBar else {
            return
        }
        
        isNavigationBarHidden = viewController?.navigationController?.isNavigationBarHidden ?? false
        
        if !isNavigationBarHidden {
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
        }
        
        stashForegroundAttr(forNavigationBar: bar)
        stashBackgroundAttr(forNavigationBar: bar)
        
        [.default, .compact, .defaultPrompt, .compactPrompt].forEach{ bar.setBackgroundImage(TransparentImage, for: $0) }
        bar.shadowImage = TransparentImage
        bar.isTranslucent = true
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

fileprivate let TransparentImage = UIImage(color: UIColor.clear)

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

private var BarHelperKey: Void?
