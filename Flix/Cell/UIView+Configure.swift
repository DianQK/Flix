//
//  UIView+Configure.swift
//  Flix
//
//  Created by DianQK on 03/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit

private var key: Void?

extension UIView {
    public var hasConfigured: Bool {
        get {
            return objc_getAssociatedObject(self, &key) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self,
                                     &key, newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
