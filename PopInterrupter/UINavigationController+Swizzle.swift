//
// UINavigationController+Swizzle.swift
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

public func load() {
    _ = __init__
}

private let __init__: Bool = {
    UINavigationController.exchange(#selector(UINavigationController.viewDidLoad), withSEL: #selector(UINavigationController.jw_viewDidLoad))
    return true
}()

extension UINavigationController {
    
    @objc func jw_viewDidLoad() {
        jw_viewDidLoad()
        
        objc_setAssociatedObject(self, &UINavigationController.originDelegateKey, interactivePopGestureRecognizer?.delegate, .OBJC_ASSOCIATION_ASSIGN)
        interactivePopGestureRecognizer?.delegate = self
    }
    
    static var originDelegateKey: Void?
}

fileprivate extension NSObject {
    
    @discardableResult
    class func exchange(_ oldSEL: Selector, withSEL newSEL: Selector) -> Bool {
        
        guard let originMethod = class_getInstanceMethod(self, oldSEL),
              let altMethod = class_getInstanceMethod(self, newSEL) else {
            return false
        }
        
        let didAddMethod = class_addMethod(self, oldSEL, method_getImplementation(altMethod), method_getTypeEncoding(altMethod))
        if didAddMethod {
            class_replaceMethod(self, newSEL, method_getImplementation(originMethod), method_getTypeEncoding(originMethod))
        } else {
            method_exchangeImplementations(originMethod, altMethod)
        }
        return true
    }
}
