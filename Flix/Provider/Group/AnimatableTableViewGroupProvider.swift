//
//  AnimatableTableViewGroupProvider.swift
//  Flix
//
//  Created by wc on 29/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public protocol AnimatableTableViewGroupProvider: _AnimatableTableViewMultiNodeProvider, _TableViewGroupProvider {

    var providers: [_AnimatableTableViewMultiNodeProvider] { get }

    func createAnimatableProviders() -> Observable<[_AnimatableTableViewMultiNodeProvider]>

}

extension AnimatableTableViewGroupProvider {

    public var _providers: [_TableViewMultiNodeProvider] {
        return self.providers.flatMap { (provider) -> [_TableViewMultiNodeProvider] in
            if let provider = provider as? _TableViewGroupProvider {
                return provider._providers
            } else {
                return [provider]
            }
        }
    }

    public func createProviders() -> Observable<[_TableViewMultiNodeProvider]> {
        return self.createAnimatableProviders().map { $0 as [_TableViewMultiNodeProvider] }
    }

    public func _createAnimatableNodes() -> Observable<[IdentifiableNode]> {
        return createAnimatableProviders().map { $0.map { $0._createAnimatableNodes() } }
            .flatMapLatest { Observable.combineLatest($0) { $0.flatMap { $0 } } }
    }

}
