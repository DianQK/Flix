//
//  CollectionViewGroupProvider.swift
//  Flix
//
//  Created by DianQK on 30/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public protocol _CollectionViewGroupProvider {

    var _providers: [_CollectionViewMultiNodeProvider] { get }

    func createProviders() -> Observable<[_CollectionViewMultiNodeProvider]>

}

extension _CollectionViewGroupProvider where Self: _CollectionViewMultiNodeProvider {

    public func _configureCell(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node) -> UICollectionViewCell {
        fatalError("group provider is abstract provider, you should never call this methods.")
    }

    public func _itemSelected(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node) {
        fatalError("group provider is abstract provider, you should never call this methods.")
    }

    public func _itemDeselected(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node) {
        fatalError("group provider is abstract provider, you should never call this methods.")
    }

    public func _collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, node: _Node) -> CGSize? {
        fatalError("group provider is abstract provider, you should never call this methods.")
    }

    public func register(_ collectionView: UICollectionView) {
        for provider in __providers {
            provider._register(collectionView)
        }
    }

    public func _createNodes() -> Observable<[Node]> {
        return createProviders().map { $0.map { $0._createNodes() } }
            .flatMapLatest { Observable.combineLatest($0) { $0.flatMap { $0 } } }
    }

}

public protocol CollectionViewGroupProvider: _CollectionViewMultiNodeProvider, _CollectionViewGroupProvider {

    var providers: [_CollectionViewMultiNodeProvider] { get }

}

extension CollectionViewGroupProvider {

    public var _providers: [_CollectionViewMultiNodeProvider] {
        return self.providers.flatMap { (provider) -> [_CollectionViewMultiNodeProvider] in
            if let provider = provider as? _CollectionViewGroupProvider {
                return provider._providers
            } else {
                return [provider]
            }
        }
    }

}
