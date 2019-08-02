//
// NavigationBarHelper+AttrRestoration.swift
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

public extension NavigationBarHelper {
    
    typealias BackgroundAttr = (backgroundImages: [UIBarMetrics: UIImage], shadowImage: UIImage?, barTintColor: UIColor?, isTranslucent: Bool)
    
    typealias ForegroundAttr = (tintColor: UIColor?, barStyle: UIBarStyle, titleAttributes: [NSAttributedString.Key: Any]?)
    
    func stashBackgroundAttr(for bar: UINavigationBar) {
        var backgroundImages = [UIBarMetrics: UIImage]()
        [UIBarMetrics.default, UIBarMetrics.compact, UIBarMetrics.defaultPrompt, UIBarMetrics.compactPrompt].forEach {
            guard let img = bar.backgroundImage(for: $0) else {
                return
            }
            backgroundImages[$0] = img
        }
        
        backgroundAttr = (backgroundImages, bar.shadowImage, bar.barTintColor, bar.isTranslucent)
    }
    
    func restoreBackgroundAttr(for bar: UINavigationBar) {
        guard var attr = backgroundAttr else {
                return
        }
        
        let notifier = viewController as? NavigationBarHelperDelegate
        notifier?.willRestore(backgroundAttr: &attr)
        
        if attr.backgroundImages.count > 0 {
            attr.backgroundImages.forEach { bar.setBackgroundImage($0.1, for: $0.0) }
        } else {
            [.default, .compact, .defaultPrompt, .compactPrompt].forEach { bar.setBackgroundImage(nil, for: $0) }
        }
        
        bar.shadowImage = attr.shadowImage
        bar.isTranslucent = attr.isTranslucent
        bar.barTintColor = attr.barTintColor
        
        notifier?.didRestore(backgroundAttr: attr)
    }
    
    func stashForegroundAttr(for bar: UINavigationBar) {
        foregroundAttr = (bar.tintColor, bar.barStyle, bar.titleTextAttributes)
    }
    
    func restoreForegroundAttr(for bar: UINavigationBar) {
        guard var attr = foregroundAttr else {
            return
        }
        
        let notifier = viewController as? NavigationBarHelperDelegate
        notifier?.willRestore(foregroundAttr: &attr)
        
        bar.tintColor = attr.tintColor
        bar.titleTextAttributes = attr.titleAttributes
        bar.barStyle = attr.barStyle

        notifier?.didRestore(foregroundAttr: attr)
        
    }
    
    internal func fixNavigationTitleView(for bar: UINavigationBar) {
        //It turns out that when the transition is ongoing, the barStyle does not change the title label correctly.
        //So we have to change the title color manually when the titleAttributes are not set.
        
        guard bar.titleTextAttributes == nil, let barForegroundContentClass = NSClassFromString("_UINavigationBarContentView") else {
            return
        }
        
        for subView in bar.subviews {
            if subView.isKind(of: barForegroundContentClass) {
                for contentView in subView.subviews {
                    if let label = contentView as? UILabel {
                        label.textColor = bar.barStyle == .default ? UIColor.black : UIColor.white
                        break
                    }
                }
                break
            }
        }
    }
}
