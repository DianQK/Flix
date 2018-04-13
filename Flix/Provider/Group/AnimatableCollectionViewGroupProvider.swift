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

    func createAnimatableProviders() -> Observable<[_AnimatableCollectionViewMultiNodeProvider]>

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

    public func createProviders() -> Observable<[_CollectionViewMultiNodeProvider]> {
        return self.createAnimatableProviders().map { $0 as [_CollectionViewMultiNodeProvider] }
    }

    public func _createAnimatableNodes() -> Observable<[IdentifiableNode]> {
        return createAnimatableProviders().map { $0.map { $0._createAnimatableNodes() } }
            .flatMapLatest { Observable.combineLatest($0) { $0.flatMap { $0 } } }
    }

}
