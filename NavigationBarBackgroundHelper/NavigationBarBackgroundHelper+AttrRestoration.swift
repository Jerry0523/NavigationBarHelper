//
// NavigationBarBackgroundHelper+AttrRestoration.swift
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

typealias NavigationBarBackgroundAttr = (backgroundImages: [UIBarMetrics: UIImage], shadowImage: UIImage?, barTintColor: UIColor?, isTranslucent: Bool)

typealias NavigationBarForegroundAttr = (tintColor: UIColor?, barStyle: UIBarStyle, titleAttributes: [NSAttributedStringKey: Any]?)

public extension NavigationBarBackgroundHelper {
    
    public func stashBackgroundAttr(forNavigationBar bar: UINavigationBar) {
        var backgroundImages = [UIBarMetrics: UIImage]()
        [UIBarMetrics.default, UIBarMetrics.compact, UIBarMetrics.defaultPrompt, UIBarMetrics.compactPrompt].forEach {
            guard let img = bar.backgroundImage(for: $0) else {
                return
            }
            backgroundImages[$0] = img
        }
        
        backgroundAttr = (backgroundImages, bar.shadowImage, bar.barTintColor, bar.isTranslucent)
    }
    
    public func restoreBackgroundAttr(forNavigationBar bar: UINavigationBar) {
        guard let attr = backgroundAttr else {
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
        
        if let notifier = self as? NavigationBarBackgroundHelperDelegate {
            notifier.navigationBarBackgroundAttrDidRestore?()
        }
    }
    
    public func stashForegroundAttr(forNavigationBar bar: UINavigationBar) {
        foregroundAttr = (bar.tintColor, bar.barStyle, bar.titleTextAttributes)
    }
    
    public func restoreForegroundAttr(forNavigationBar bar: UINavigationBar) {
        guard let attr = foregroundAttr else {
            return
        }
        
        var shouldManageBarRestoration = true
        
        if let notifier = viewController as? NavigationBarBackgroundHelperDelegate {
            shouldManageBarRestoration = !(notifier.takeOverNavigationBarForegroundAttrRestoration?() ?? false)
        }
        
        if shouldManageBarRestoration {
            bar.tintColor = attr.tintColor
            bar.titleTextAttributes = attr.titleAttributes
            bar.barStyle = attr.barStyle
        }
        
        if let notifier = viewController as? NavigationBarBackgroundHelperDelegate {
            notifier.navigationBarForegroundAttrDidRestore?()
        }
        
        ///It turns out that when the transition is ongoing, the barStyle does not change the title label correctly.
        ///So we have to change the title color manually when the titleAttributes are not set.
        guard attr.titleAttributes == nil, let barForegroundContentClass = NSClassFromString("_UINavigationBarContentView") else {
            return
        }
        
        for subView in bar.subviews {
            if subView.isKind(of: barForegroundContentClass) {
                for contentView in subView.subviews {
                    if let label = contentView as? UILabel {
                        label.textColor = attr.barStyle == .default ? UIColor.black : UIColor.white
                        break
                    }
                }
                break
            }
        }
    }
}
