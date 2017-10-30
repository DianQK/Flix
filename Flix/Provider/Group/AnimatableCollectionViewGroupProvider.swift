//
//  AnimatableCollectionViewGroupProvider.swift
//  Flix
//
//  Created by DianQK on 30/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public protocol AnimatableCollectionViewGroupProvider: _AnimatableCollectionViewMultiNodeProvider, _CollectionViewGroupProvider {

    var providers: [_AnimatableCollectionViewMultiNodeProvider] { get }

    func genteralAnimatableProviders() -> Observable<[_AnimatableCollectionViewMultiNodeProvider]>

}

extension AnimatableCollectionViewGroupProvider {

    public var _providers: [_CollectionViewMultiNodeProvider] {
        return self.providers.flatMap { (provider) -> [_CollectionViewMultiNodeProvider] in
            if let provider = provider as? _CollectionViewGroupProvider {
                return provider._providers
            } else {
                return [provider]
            }
        }
    }

    public func genteralProviders() -> Observable<[_CollectionViewMultiNodeProvider]> {
        return self.genteralAnimatableProviders().map { $0 as [_CollectionViewMultiNodeProvider] }
    }

    public func _genteralAnimatableNodes() -> Observable<[IdentifiableNode]> {
        return genteralAnimatableProviders().map { $0.map { $0._genteralAnimatableNodes() } }
            .flatMapLatest { Observable.combineLatest($0) { $0.flatMap { $0 } } }
    }

}
