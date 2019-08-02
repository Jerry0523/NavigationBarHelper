//
// NavigationBarHelper.swift
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
    
    open var navigationBarHelper: NavigationBarHelper {
        
        get {
            var handler = getStoredNavigationBarHelper()
            if handler == nil {
                handler = NavigationBarHelper(viewController: self)
                self.navigationBarHelper = handler!
            }
            return handler!
        }
        
        set {
            objc_setAssociatedObject(self, &BarHelperKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
    }
    
    var previousNavigationBarHelper: NavigationBarHelper? {
        get {
            guard let vcs = navigationController?.viewControllers, vcs.count >= 2 else {
                return nil
            }
            return vcs[vcs.count - 2].getStoredNavigationBarHelper()
        }
    }
    
    func getStoredNavigationBarHelper() -> NavigationBarHelper? {
        return objc_getAssociatedObject(self, &BarHelperKey) as? NavigationBarHelper
    }
    
}

public protocol NavigationBarHelperDelegate {
    
    /// Called before the mirror view capturing the bar's background attribute.
    /// Modify the backgroundAttr if it is not your appetite
    func willRestore(backgroundAttr: inout NavigationBarHelper.BackgroundAttr)
    
    /// Called after the mirror view capturing the bar's background attribute.
    /// It is the best time for you to do additional change to the bar's background attr.
    /// After this function is called, the mirror background view will synchronize with the bar's background.
    func didRestore(backgroundAttr: NavigationBarHelper.BackgroundAttr)
    
    /// Called before the navigation bar's foreground attribute being restored, especially when the viewController's appearing.
    /// Modify the foregroundAttr if it is not your appetite
    func willRestore(foregroundAttr: inout NavigationBarHelper.ForegroundAttr)
    
    /// Called after the navigation bar's foreground attribute being restored, especially when the viewController's appearing.
    /// Do additional change if you have modified the navigation bar out of the performNavigationBarUpdates scope.(e.g, you have set the bar tint color according to scrollview offset)
    func didRestore(foregroundAttr: NavigationBarHelper.ForegroundAttr)
    
}

public final class NavigationBarHelper {
    
    /// A type indicates the transition style for the navigation bar
    public enum TranstionStyle {
        
        ///iOS' default style. perform a fade like transition
        case system
        
        ///android default style. The navigation bar is attached to the viewController.
        case followPage
        
    }
    
    public static var transitionStyle = TranstionStyle.system
    
    public private(set) var view: NavigationBarBackgroundView?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    ///This function is to be called in viewDidLoad.
    ///Apis to change the navigation bar should be called within this scope.
    ///After called,any attribute (background image/tintColor/barTintColor/barStyle etc) will be remembered by the library.
    ///It will create a mirror background view of the navigation bar (auto managed) and clear the bar background (to provide a smooth transition).
    ///Any change to the navigation bar's background (background image/barTintColor/barStyle/shadowImage) within the scope will be syncronized with the mirror view.
    public func perform(_ action: ((UINavigationBar) -> ())?) {
        guard let bar = viewController?.navigationController?.navigationBar else {
            return
        }
        beginUpdate(with: bar)
        action?(bar)
        endUpdate(with: bar)
    }
    
    public func setNeedsLayout() {
        guard let vc = viewController else {
            return
        }
        
        var insetsTop = CGFloat(0)
        if #available(iOS 11.0, *) {
            insetsTop = max(vc.view.safeAreaInsets.top, vc.navigationController?.navigationBar.frame.size.height ?? 0)
        } else {
            insetsTop = max(vc.topLayoutGuide.length, vc.navigationController?.navigationBar.frame.size.height ?? 0)
        }
        view?.frame = CGRect(x: 0, y: 0 + (view?.transform.ty ?? 0), width: view?.frame.size.width ?? 0, height: insetsTop)
    }
    
    func synchronizeForegroundAttr() {
        guard let nc = viewController?.navigationController else {
            return
        }
        let bar = nc.navigationBar
        restoreForegroundAttr(for: bar)
        view?.isHidden = isNavigationBarHidden
    }
    
    func snapshotNavigationRegion() {
        guard
            let nc = viewController?.navigationController,
            let view = view,
            nc.isViewLoaded && !view.isHidden else {
            return
        }
        if let snapshotView = nc.view.resizableSnapshotView(from: CGRect(origin: CGPoint.zero, size: view.frame.size), afterScreenUpdates: false, withCapInsets: UIEdgeInsets.zero) {
            snapshotView.tag = NavigationRegionSnapshotViewTag
            snapshotView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(snapshotView)
        }
    }
    
    func removeNavigationRegionSnapshot() {
        guard let view = view, !view.isHidden else {
                return
        }
        let snapshotView = view.viewWithTag(NavigationRegionSnapshotViewTag)
        snapshotView?.removeFromSuperview()
    }
    
    func clearForegroundAttr(isRestoreEnabled: Bool) {
        if isRestoreEnabled {
            let title = viewController?.navigationItem.title
            let titleView = viewController?.navigationItem.titleView
            let prompt = viewController?.navigationItem.prompt
            let leftBarButtonItems = viewController?.navigationItem.leftBarButtonItems
            let rightBarButtonItem = viewController?.navigationItem.rightBarButtonItem
            let isHidesBackButton = viewController?.navigationItem.hidesBackButton ?? false
            
            restoreClearedForegroundOperation = { [weak viewController] in
                viewController?.navigationItem.title = title
                viewController?.navigationItem.titleView = titleView
                viewController?.navigationItem.prompt = prompt
                viewController?.navigationItem.leftBarButtonItems = leftBarButtonItems
                viewController?.navigationItem.rightBarButtonItem = rightBarButtonItem
                viewController?.navigationItem.setHidesBackButton(isHidesBackButton, animated: false)
            }
        }
        viewController?.navigationController?.navigationBar.tintColor = UIColor.clear
        viewController?.navigationItem.title = nil
        viewController?.navigationItem.titleView = nil
        viewController?.navigationItem.prompt = nil
        viewController?.navigationItem.leftBarButtonItems = nil
        viewController?.navigationItem.rightBarButtonItem = nil
        viewController?.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    func restoreClearedForegroundAttr() {
        restoreClearedForegroundOperation?()
        restoreClearedForegroundOperation = nil
    }
    
    var backgroundAttr: BackgroundAttr?
    
    var foregroundAttr: ForegroundAttr?
    
    var isNavigationBarHidden = false
    
    var isNavigationRegionSnapshotted: Bool {
        get {
            return view?.viewWithTag(NavigationRegionSnapshotViewTag) != nil
        }
    }
    
    weak var viewController: UIViewController?
    
    var keyPathObservations: [NSKeyValueObservation]?
    
    var restoreClearedForegroundOperation: (() -> ())?
    
}

extension NavigationBarHelper {
    
    public class func load() {
        _ = __init__
    }
    
}

extension NavigationBarHelper {
    
    private func beginUpdate(with bar: UINavigationBar) {
        
        guard let previousHelper = viewController?.previousNavigationBarHelper else {
                return
        }
        previousHelper.restoreBackgroundAttr(for: bar)
    }
    
    private func endUpdate(with bar: UINavigationBar) {
        guard viewController?.isViewLoaded ?? false, let containerView = viewController?.view else {
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
            containerView.addSubview(view!)
            if let scrollView = containerView as? UIScrollView {
                keyPathObservations = [
                    scrollView.observe(\.contentOffset, options: .new, changeHandler: { [weak self] (scrollView, change) in
                        self?.view?.transform = CGAffineTransform(translationX: 0, y: change.newValue?.y ?? 0)
                    })
                ]
            }
        } else {
            //Here, we set the navigation bar visible, to provide a smooth transition.
            //To confirm to the user's set, we play a trick to fade that the navigation bar is hidden.
            //To do so, we clear all the foreground attr and set the bgView hidden.
            //On iOS 11, we provide an negative insets top to cancel out the navigation bar's position
            viewController?.navigationController?.setNavigationBarHidden(false, animated: false)
            if #available(iOS 11.0, *) {
                viewController?.additionalSafeAreaInsets = UIEdgeInsets(top: -(viewController?.navigationController?.navigationBar.bounds.height ?? 0), left: 0, bottom: 0, right: 0)
            } else {
                //unsupported yet
            }
            clearForegroundAttr(isRestoreEnabled: false)
        }
        
        stashForegroundAttr(for: bar)
        stashBackgroundAttr(for: bar)
    [.default, .compact, .defaultPrompt, .compactPrompt].forEach{ bar.setBackgroundImage(UIImage.transparent, for: $0) }
        bar.shadowImage = UIImage.transparent
        bar.isTranslucent = true
    }
    
}

fileprivate let __init__: Bool = {
    do {
        if #available(iOS 11.0, *) {
            try UIViewController.exchange(#selector(UIViewController.viewSafeAreaInsetsDidChange), withSEL: #selector(UIViewController.jw_swizzling_UIViewController_viewSafeAreaInsetsDidChange))
        } else {
            try UIViewController.exchange(#selector(UIViewController.viewWillLayoutSubviews), withSEL: #selector(UIViewController.jw_swizzling_UIViewController_viewWillLayoutSubViews))
        }
        try UIViewController.exchange(#selector(UIViewController.viewWillAppear(_:)), withSEL: #selector(UIViewController.jw_swizzling_UIViewController_viewWillAppear(_:)))
        try UIViewController.exchange(#selector(UIViewController.viewDidAppear(_:)), withSEL: #selector(UIViewController.jw_swizzling_UIViewController_viewDidAppear(_:)))
        try UIViewController.exchange(#selector(UIViewController.viewWillDisappear(_:)), withSEL: #selector(UIViewController.jw_swizzling_UIViewController_viewWillDisappear(_:)))
        try UINavigationBar.exchange(#selector(UINavigationBar.hitTest(_:with:)), withSEL: #selector(UINavigationBar.jw_swizzling_UINavigationBar_hitTest(_:with:)))
    } catch {
        debugPrint(error)
    }
    return true
}()

private var BarHelperKey: Void?

private let NavigationRegionSnapshotViewTag = 1011
