//
//  __init__.swift
//  JWKit
//
//  Created by Jerry on 2017/11/2.
//  Copyright © 2017年 com.jerry. All rights reserved.
//

import UIKit

func load() {
    _ = __init__
}

private let __init__: Bool = {
    UINavigationController.exchange(#selector(UINavigationController.viewDidLoad), withSEL: #selector(UINavigationController.jw_viewDidLoad))
    return true
}()

fileprivate extension NSObject {
    
    @discardableResult
    fileprivate class func exchange(_ oldSEL: Selector, withSEL newSEL: Selector) -> Bool {
        
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
