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
    
    internal static let transparent = { UIImage(color: UIColor.clear)! }()
    
}

extension UIBarStyle {
    
    var shadowColor: UIColor {
        switch self {
        case .default:
            return UIColor(white: 0, alpha: 0.3)
        case .black, .blackTranslucent:
            return UIColor(white: 1.0, alpha: 0.15)
        @unknown default:
            return UIColor(white: 0, alpha: 0.3)
        }
    }
    
    var defaultBlurEffectConfig: (UIBlurEffect.Style, UIColor) {
        switch self {
        case .default:
            return (.light, UIColor(white: 0.97, alpha: 0.8))
        case .black, .blackTranslucent:
            return (.dark, UIColor(white: 0.11, alpha: 0.73))
        @unknown default:
            return (.light, UIColor(white: 0.97, alpha: 0.8))
        }
    }
    
}
