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

public protocol _CollectionViewMultiNodeProvider {

    var identity: String { get }
    
    func _configureCell(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node) -> UICollectionViewCell
    
    func _tap(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node)
    
    func _genteralNodes() -> Observable<[_Node]>
    
    func _collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, node: _Node) -> CGSize?
    
    func register(_ collectionView: UICollectionView)
    
}

public protocol CollectionViewMultiNodeProvider: _CollectionViewMultiNodeProvider {

    associatedtype Value
    
    func configureCell(_ collectionView: UICollectionView, indexPath: IndexPath, node: Value) -> UICollectionViewCell

    func tap(_ collectionView: UICollectionView, indexPath: IndexPath, node: Value)
    
    func genteralNodes() -> Observable<[Value]>

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, node: Value) -> CGSize?
}


extension CollectionViewMultiNodeProvider {
    
    public func _configureCell(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node) -> UICollectionViewCell {
        if let valueNode = node as? ValueNode<Value> {
            return self.configureCell(collectionView, indexPath: indexPath, node: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func _tap(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node) {
        if let valueNode = node as? ValueNode<Value> {
            tap(collectionView, indexPath: indexPath, node: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func _genteralNodes() -> Observable<[_Node]> {
        let providerIdentity = self.identity
        return genteralNodes()
            .map { $0.map { ValueNode(providerIdentity: providerIdentity, value: $0) } }
    }
    
    public func _collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, node: _Node) -> CGSize? {
        if let valueNode = node as? ValueNode<Value> {
            return self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath, node: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, node: Value) -> CGSize? {
        return nil
    }
    
}

public protocol CollectionViewProvider: CollectionViewMultiNodeProvider {
    
    associatedtype Cell: UICollectionViewCell
    
    func configureCell(_ collectionView: UICollectionView, cell: Cell, indexPath: IndexPath, node: Value)

}

extension CollectionViewProvider {
    
    public func register(_ collectionView: UICollectionView) {
        collectionView.register(Cell.self, forCellWithReuseIdentifier: self.identity)
    }
    
    public func configureCell(_ collectionView: UICollectionView, indexPath: IndexPath, node: Value) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.identity, for: indexPath)
        self.configureCell(collectionView, cell: cell as! Cell, indexPath: indexPath, node: node)
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
    
    public func _configureCell(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node) -> UICollectionViewCell {
        if let valueNode = node as? IdentifiableValueNode<Value> {
            return self.configureCell(collectionView, indexPath: indexPath, node: valueNode.value)
        } else {
            fatalError()
        }
    }

    public func _tap(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node) {
        if let valueNode = node as? IdentifiableValueNode<Value> {
            tap(collectionView, indexPath: indexPath, node: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func _collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, node: _Node) -> CGSize? {
        if let valueNode = node as? IdentifiableValueNode<Value> {
            return self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath, node: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func genteralAnimatableNodes() -> Observable<[IdentifiableNode]> {
        let providerIdentity = self.identity
        return genteralNodes()
            .map { $0.map { IdentifiableNode(node: IdentifiableValueNode(providerIdentity: providerIdentity, value: $0)) } }
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
    
    public func configureCell(_ collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: IndexPath, node: Self) {
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
    
    public func genteralNodes() -> Observable<[Self]> {
        return Observable.just([self])
    }

}
