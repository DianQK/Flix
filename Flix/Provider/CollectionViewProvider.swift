//
//  CollectionViewProvider.swift
//  Flix
//
//  Created by DianQK on 03/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

public protocol _CollectionViewMultiNodeProvider: FlixCustomStringConvertible {

    func _configureCell(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node) -> UICollectionViewCell
    
    func _tap(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node)
    
    func _genteralNodes() -> Observable<[Node]>
    
    func _collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, node: _Node) -> CGSize?
    
    func register(_ collectionView: UICollectionView)

}

extension _CollectionViewMultiNodeProvider {

    var __providers: [_CollectionViewMultiNodeProvider] {
        if let groupProvider = self as? _CollectionViewGroupProvider {
            return groupProvider._providers
        } else {
            return [self]
        }
    }

}

public protocol CollectionViewMultiNodeProvider: _CollectionViewMultiNodeProvider {

    associatedtype Value
    
    func configureCell(_ collectionView: UICollectionView, indexPath: IndexPath, value: Value) -> UICollectionViewCell

    func tap(_ collectionView: UICollectionView, indexPath: IndexPath, value: Value)
    
    func genteralValues() -> Observable<[Value]>

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, value: Value) -> CGSize?
}

extension CollectionViewMultiNodeProvider {
    
    public func tap(_ collectionView: UICollectionView, indexPath: IndexPath, value: Value) {
        
    }
    
    public func _configureCell(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node) -> UICollectionViewCell {
        return self.configureCell(collectionView, indexPath: indexPath, value: node._unwarp())
    }
    
    public func _tap(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node) {
        self.tap(collectionView, indexPath: indexPath, value: node._unwarp())
    }
    
    public func _genteralNodes() -> Observable<[Node]> {
        let providerIdentity = self._flix_identity
        return genteralValues()
            .map { $0.map { Node(providerIdentity: providerIdentity, value: $0) } }
    }
    
    public func _collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, node: _Node) -> CGSize? {
        return self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath, value: node._unwarp())
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, value: Value) -> CGSize? {
        return nil
    }
    
}

public protocol CollectionViewProvider: CollectionViewMultiNodeProvider {
    
    associatedtype Cell: UICollectionViewCell
    
    func configureCell(_ collectionView: UICollectionView, cell: Cell, indexPath: IndexPath, value: Value)

}

extension CollectionViewProvider {
    
    public func register(_ collectionView: UICollectionView) {
        collectionView.register(Cell.self, forCellWithReuseIdentifier: self._flix_identity)
    }
    
    public func configureCell(_ collectionView: UICollectionView, indexPath: IndexPath, value: Value) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self._flix_identity, for: indexPath)
        self.configureCell(collectionView, cell: cell as! Cell, indexPath: indexPath, value: value)
        return cell
    }
    
}

public protocol _AnimatableProviderable {
    
    func _genteralAnimatableNodes() -> Observable<[IdentifiableNode]>
    
}

public typealias _AnimatableCollectionViewMultiNodeProvider = _AnimatableProviderable & _CollectionViewMultiNodeProvider

public protocol AnimatableCollectionViewMultiNodeProvider: CollectionViewMultiNodeProvider, _AnimatableProviderable where Value: Equatable, Value: StringIdentifiableType {
    
    func genteralAnimatableNodes() -> Observable<[IdentifiableNode]>
    
}

public typealias AnimatableCollectionViewProvider = AnimatableCollectionViewMultiNodeProvider & CollectionViewProvider

extension AnimatableCollectionViewMultiNodeProvider {
    
    public func _genteralAnimatableNodes() -> Observable<[IdentifiableNode]> {
        return genteralAnimatableNodes()
    }
    
}

extension AnimatableCollectionViewMultiNodeProvider {
    
    public func genteralAnimatableNodes() -> Observable<[IdentifiableNode]> {
        let providerIdentity = self._flix_identity
        return genteralValues().map { $0.map { IdentifiableNode(providerIdentity: providerIdentity, valueNode: $0) } }
    }
    
}

public typealias _UniqueAnimatableCollectionViewProvider = AnimatableCollectionViewProvider & Equatable & StringIdentifiableType

public protocol UniqueAnimatableCollectionViewProvider: _UniqueAnimatableCollectionViewProvider /* where ValueType == Self,  Cell == UICollectionViewCell */ {
    
    func onCreate(_ collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: IndexPath)
    func onUpdate(_ collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: IndexPath)

}

extension UniqueAnimatableCollectionViewProvider {
    
    public func onUpdate(_ collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: IndexPath) {
        
    }
    
    public func configureCell(_ collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: IndexPath, value: Self) {
        if !cell.hasConfigured {
            cell.hasConfigured = true
            onCreate(collectionView, cell: cell, indexPath: indexPath)
        }
        onUpdate(collectionView, cell: cell, indexPath: indexPath)
    }
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return true
    }
    
    public var providerIdentity: String {
        return self.identity
    }
    
    public var identity: String {
        return self._flix_identity
    }
    
    public func genteralValues() -> Observable<[Self]> {
        return Observable.just([self])
    }

}
