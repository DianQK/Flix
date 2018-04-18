//
//  CollectionViewMoveable.swift
//  Flix
//
//  Created by DianQK on 14/11/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

public protocol _CollectionViewMoveable {

    func _collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath, node: _Node) -> Bool

    func _collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndex: Int, to destinationIndex: Int, node: _Node)

}

public protocol CollectionViewMoveable: _CollectionViewMoveable {

    associatedtype Value

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath, value: Value) -> Bool

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndex: Int, to destinationIndex: Int, value: Value)

}

extension CollectionViewMoveable where Self: CollectionViewMultiNodeProvider {

    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath, value: Self.Value) -> Bool {
        return true
    }

    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndex: Int, to destinationIndex: Int, value: Self.Value) { }

    public func _collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath, node: _Node) -> Bool {
        return self.collectionView(collectionView, canMoveItemAt: indexPath, value: node._unwarp())
    }

    public func _collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndex: Int, to destinationIndex: Int, node: _Node) {
        self.collectionView(collectionView, moveItemAt: sourceIndex, to: destinationIndex, value: node._unwarp())
        self.event._moveItem.onNext((
            collectionView: collectionView,
            sourceIndex: sourceIndex,
            destinationIndex: destinationIndex,
            value: node._unwarp())
        )
    }

}

extension CollectionViewEvent where Provider: CollectionViewMoveable {

    public var moveItem: ControlEvent<MoveEventValue> {
        return ControlEvent(events: self._moveItem)
    }

}
