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

public protocol _CollectionViewProvider {

    var identity: String { get }
    var cellType: UICollectionViewCell.Type { get }
    
    func _configureCell(_ collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: IndexPath, node: _Node)

    func _tap(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node)

    func _genteralNodes() -> Observable<[_Node]>
    
    func _collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, node: _Node) -> CGSize?
}

extension _CollectionViewProvider {
    
    public func register(_ collectionView: UICollectionView) {
        collectionView.register(self.cellType, forCellWithReuseIdentifier: self.identity)
    }

}

public protocol CollectionViewProvider: _CollectionViewProvider {
    
    associatedtype CellType: UICollectionViewCell
    associatedtype ValueType
    
    func configureCell(_ collectionView: UICollectionView, cell: CellType, indexPath: IndexPath, node: ValueType)
    func tap(_ collectionView: UICollectionView, indexPath: IndexPath, node: ValueType)
    
    func genteralNodes() -> Observable<[ValueType]>
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, node: ValueType) -> CGSize?
    
}

extension CollectionViewProvider {
    
    public var cellType: UICollectionViewCell.Type { return CellType.self }
    
    public func _configureCell(_ collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: IndexPath, node: _Node) {
        if let valueNode = node as? ValueNode<ValueType> {
            configureCell(collectionView, cell: cell as! CellType, indexPath: indexPath, node: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func _tap(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node) {
        if let valueNode = node as? ValueNode<ValueType> {
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
        if let valueNode = node as? ValueNode<ValueType> {
            return self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath, node: valueNode.value)
        } else {
            fatalError()
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, node: ValueType) -> CGSize? {
        return nil
    }
    
}

public protocol _AnimatableProviderable {
    
    func _genteralAnimatableNodes() -> Observable<[IdentifiableNode]>
    
}

public typealias _AnimatableCollectionViewProvider = _AnimatableProviderable & _CollectionViewProvider

public protocol AnimatableCollectionViewProvider: CollectionViewProvider, _AnimatableProviderable where ValueType: Equatable, ValueType: StringIdentifiableType {
    
    func genteralAnimatableNodes() -> Observable<[IdentifiableNode]>
    
}

extension AnimatableCollectionViewProvider {
    
    public func _genteralAnimatableNodes() -> Observable<[IdentifiableNode]> {
        return genteralAnimatableNodes()
    }
    
}

extension AnimatableCollectionViewProvider {
    
    public func _configureCell(_ collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: IndexPath, node: _Node) {
        if let valueNode = node as? IdentifiableValueNode<ValueType> {
            configureCell(collectionView, cell: cell as! CellType, indexPath: indexPath, node: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func _tap(_ collectionView: UICollectionView, indexPath: IndexPath, node: _Node) {
        if let valueNode = node as? IdentifiableValueNode<ValueType> {
            tap(collectionView, indexPath: indexPath, node: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func _collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, node: _Node) -> CGSize? {
        if let valueNode = node as? IdentifiableValueNode<ValueType> {
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

public protocol UniqueAnimatableCollectionViewProvider: _UniqueAnimatableCollectionViewProvider where /* ValueType == Self, */ CellType == UICollectionViewCell {
    
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
