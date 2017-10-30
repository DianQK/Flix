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

    public func _configureCell(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node) -> UICollectionViewCell {
        fatalError("group provider is abstract provider, you should never call this methods.")
    }

    public func _tap(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node) {
        fatalError("group provider is abstract provider, you should never call this methods.")
    }

    public func _collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, node: _Node) -> CGSize? {
        fatalError("group provider is abstract provider, you should never call this methods.")
    }

    public func register(_ collectionView: UICollectionView) {
        for provider in __providers {
            provider.register(collectionView)
        }
    }

    public var _providers: [_CollectionViewMultiNodeProvider] {
        return self.providers.flatMap { (provider) -> [_CollectionViewMultiNodeProvider] in
            if let provider = provider as? _CollectionViewGroupProvider {
                return provider._providers
            } else {
                return [provider]
            }
        }
    }

    public func _genteralNodes() -> Observable<[Node]> {
        return genteralProviders().map { $0.map { $0._genteralNodes() } }
            .flatMapLatest { Observable.combineLatest($0) { $0.flatMap { $0 } } }
    }

    public func genteralProviders() -> Observable<[_CollectionViewMultiNodeProvider]> {
        return self.genteralAnimatableProviders().map { $0 as [_CollectionViewMultiNodeProvider] }
    }

    public func _genteralAnimatableNodes() -> Observable<[IdentifiableNode]> {
        return genteralAnimatableProviders().map { $0.map { $0._genteralAnimatableNodes() } }
            .flatMapLatest { Observable.combineLatest($0) { $0.flatMap { $0 } } }
    }

}
