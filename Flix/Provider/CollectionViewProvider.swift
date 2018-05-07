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

    func _collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath, node: _Node) -> Bool

    func _itemSelected(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node)

    func _itemDeselected(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node)
    
    func _createNodes() -> Observable<[Node]>
    
    func _collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, node: _Node) -> CGSize?
    
    func _register(_ collectionView: UICollectionView)

}

private var _collectionViewKey: Void?

extension _CollectionViewMultiNodeProvider {

    var __providers: [_CollectionViewMultiNodeProvider] {
        if let groupProvider = self as? _CollectionViewGroupProvider {
            return groupProvider._providers
        } else {
            return [self]
        }
    }

    public fileprivate(set) var collectionView: UICollectionView? {
        get {
            return objc_getAssociatedObject(self, &_collectionViewKey) as? UICollectionView
        }
        set {
            objc_setAssociatedObject(self, &_collectionViewKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    public func _register(_ collectionView: UICollectionView) { }

}

public protocol CollectionViewMultiNodeProvider: _CollectionViewMultiNodeProvider, ReactiveCompatible {

    associatedtype Value
    
    func configureCell(_ collectionView: UICollectionView, indexPath: IndexPath, value: Value) -> UICollectionViewCell

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath, value: Value) -> Bool

    func itemSelected(_ collectionView: UICollectionView, indexPath: IndexPath, value: Value)

    func itemDeselected(_ collectionView: UICollectionView, indexPath: IndexPath, value: Value)
    
    func createValues() -> Observable<[Value]>

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, value: Value) -> CGSize?

    func register(_ collectionView: UICollectionView)

}

extension CollectionViewMultiNodeProvider {

    public func _register(_ collectionView: UICollectionView) {
        self.register(collectionView)
        self.collectionView = collectionView
    }

    public func _collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath, node: _Node) -> Bool {
        return self.collectionView(collectionView, shouldSelectItemAt: indexPath, value: node._unwarp())
    }

    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath, value: Value) -> Bool {
        return true
    }
    
    public func itemSelected(_ collectionView: UICollectionView, indexPath: IndexPath, value: Value) { }

    public func itemDeselected(_ collectionView: UICollectionView, indexPath: IndexPath, value: Value) { }
    
    public func _configureCell(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node) -> UICollectionViewCell {
        return self.configureCell(collectionView, indexPath: indexPath, value: node._unwarp())
    }
    
    public func _itemSelected(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node) {
        self.itemSelected(collectionView, indexPath: indexPath, value: node._unwarp())
        self.event._itemSelected.onNext((collectionView: collectionView, indexPath: indexPath, value: node._unwarp()))
    }

    public func _itemDeselected(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node) {
        self.itemDeselected(collectionView, indexPath: indexPath, value: node._unwarp())
        self.event._itemDeselected.onNext((collectionView: collectionView, indexPath: indexPath, value: node._unwarp()))
    }
    
    public func _createNodes() -> Observable<[Node]> {
        let providerIdentity = self._flix_identity
        return createValues()
            .map { $0.map { Node(providerIdentity: providerIdentity, value: $0) } }
    }
    
    public func _collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, node: _Node) -> CGSize? {
        return self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath, value: node._unwarp())
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, value: Value) -> CGSize? {
        return nil
    }
    
}

private var providerEventKey: Void?

extension CollectionViewMultiNodeProvider {

    public var event: CollectionViewEvent<Self> {
        if let event = objc_getAssociatedObject(self, &providerEventKey) as? CollectionViewEvent<Self> {
            return event
        } else {
            let event = CollectionViewEvent<Self>()
            objc_setAssociatedObject(self, &providerEventKey, event, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return event
        }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self._flix_identity, for: indexPath) as! Cell
        self.configureCell(collectionView, cell: cell, indexPath: indexPath, value: value)
        return cell
    }
    
}

public protocol _AnimatableProviderable {
    
    func _createAnimatableNodes() -> Observable<[IdentifiableNode]>
    
}

public typealias _AnimatableCollectionViewMultiNodeProvider = _AnimatableProviderable & _CollectionViewMultiNodeProvider

public protocol AnimatableCollectionViewMultiNodeProvider: CollectionViewMultiNodeProvider, _AnimatableProviderable where Value: Equatable, Value: StringIdentifiableType {
    
    func createAnimatableNodes() -> Observable<[IdentifiableNode]>
    
}

public typealias AnimatableCollectionViewProvider = AnimatableCollectionViewMultiNodeProvider & CollectionViewProvider

extension AnimatableCollectionViewMultiNodeProvider {
    
    public func _createAnimatableNodes() -> Observable<[IdentifiableNode]> {
        return createAnimatableNodes()
    }
    
}

extension AnimatableCollectionViewMultiNodeProvider {
    
    public func createAnimatableNodes() -> Observable<[IdentifiableNode]> {
        let providerIdentity = self._flix_identity
        return createValues().map { $0.map { IdentifiableNode(providerIdentity: providerIdentity, valueNode: $0) } }
    }
    
}

public protocol UniqueAnimatableCollectionViewProvider: AnimatableCollectionViewProvider, Equatable, StringIdentifiableType {
    
    func onCreate(_ collectionView: UICollectionView, cell: Cell, indexPath: IndexPath)
    func onUpdate(_ collectionView: UICollectionView, cell: Cell, indexPath: IndexPath)

}

extension UniqueAnimatableCollectionViewProvider {
    
    public func onUpdate(_ collectionView: UICollectionView, cell: Cell, indexPath: IndexPath) {
        
    }
    
    public func configureCell(_ collectionView: UICollectionView, cell: Cell, indexPath: IndexPath, value: Self) {
        if !cell.hasConfigured {
            cell.hasConfigured = true
            onCreate(collectionView, cell: cell, indexPath: indexPath)
        }
        onUpdate(collectionView, cell: cell, indexPath: indexPath)
    }
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs === rhs
    }
    
    public var providerIdentity: String {
        return self.identity
    }
    
    public var identity: String {
        return self._flix_identity
    }
    
    public func createValues() -> Observable<[Self]> {
        return Observable.just([self])
    }

}

extension UniqueAnimatableCollectionViewProvider where Self: CustomProvider {

    public func configureCell(_ collectionView: UICollectionView, indexPath: IndexPath, value: Value) -> UICollectionViewCell {
        let cell: Cell = self.cell ?? (collectionView.dequeueReusableCell(withReuseIdentifier: self._flix_identity, for: indexPath) as! Cell)
        self.configureCell(collectionView, cell: cell, indexPath: indexPath, value: value)
        return cell
    }

}
