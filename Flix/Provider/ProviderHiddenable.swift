//
//  ProviderHiddenable.swift
//  Flix
//
//  Created by DianQK on 2018/4/24.
//  Copyright © 2018 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public protocol ProviderHiddenable: class, ReactiveCompatible {

    var isHidden: Bool { get set }

}

extension Reactive where Base: ProviderHiddenable {

    public var isHidden: Binder<Bool> {
        return Binder(self.base, binding: { (provider, isHidden) in
            provider.isHidden = isHidden
        })
    }

}
