//
// NavigationBarBackgroundView.swift
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

open class NavigationBarBackgroundView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
        
        shadowImageView.frame = CGRect(x: 0, y: frame.size.height - shadowHeight, width: frame.size.width, height: shadowHeight)
        shadowImageView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        addSubview(shadowImageView)
    }
    
    convenience init(navigationBar: UINavigationBar) {
        self.init(frame: navigationBar.bounds)
        update(withNavigationBar: navigationBar)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func update(withNavigationBar bar: UINavigationBar) {
        let backgroundImg = bar.backgroundImage(for: .default)
        frame = bar.bounds
        update(withBackgroundImage: backgroundImg,
                      barTintColor: bar.barTintColor,
                     isTranslucent: bar.isTranslucent,
                          barStyle: bar.barStyle,
                       shadowImage: bar.shadowImage)
    }
    
    open func update(withBackgroundImage image: UIImage?,
                                  barTintColor: UIColor?,
                                 isTranslucent: Bool,
                                      barStyle: UIBarStyle,
                                   shadowImage: UIImage?) {
        
        contentView.subviews.forEach{ $0.removeFromSuperview() }
        var mShadowImage = shadowImage
        //A bool indicates whether the shadow is on top of the content view.
        var isShadowTop = true
        if image == nil {
            if let barTintColor = barTintColor {
                if isTranslucent {
                    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
                    blurView.frame = contentView.bounds
                    blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    self.addSubview(blurView)
                    
                    blurView.contentView.backgroundColor = UIColor.init(white: 0.97, alpha: 0.5)
                    let tintColorView = UIView(frame: blurView.bounds)
                    tintColorView.backgroundColor = barTintColor
                    tintColorView.alpha = 0.85
                    tintColorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    blurView.contentView.addSubview(tintColorView)
                } else {
                    self.backgroundColor = barTintColor
                }
            } else {
                if isTranslucent {
                    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: barStyle.defaultBlurEffectConfig.0))
                    blurView.contentView.backgroundColor = barStyle.defaultBlurEffectConfig.1
                    //It turns out that when the bar is dark, the contentView makes the backgroundView darker. So we remove it.
                    if barStyle.defaultBlurEffectConfig.0 == .dark {
                        blurView.contentView.removeFromSuperview()
                    }
                    blurView.frame = contentView.bounds
                    blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    self.addSubview(blurView)
                } else {
                    self.backgroundColor = UIColor(white: (barStyle == .default ? 1.0 : 0.0), alpha: 1.0)
                }
            }
            mShadowImage = UIImage(color: barStyle.shadowColor)
            isShadowTop = isTranslucent
        } else {
            let imageView = UIImageView(image: image)
            imageView.frame = contentView.bounds
            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.addSubview(imageView)
            mShadowImage = shadowImage ?? UIImage(color: barStyle.shadowColor)
            isShadowTop = true
        }
        
        bringSubviewToFront(isShadowTop ? shadowImageView : contentView)
        shadowImageView.image = mShadowImage
    }
    
    private let shadowHeight = 1.0 / UIScreen.main.scale
    
    private let contentView = UIView()
    
    private let shadowImageView = UIImageView()
    
}
