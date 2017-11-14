//
//  CollectionViewMoveable.swift
//  Flix
//
//  Created by DianQK on 14/11/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
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

extension CollectionViewMoveable {

    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath, value: Value) -> Bool {
        return true
    }

}

extension CollectionViewMoveable {

    public func _collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath, node: _Node) -> Bool {
        return self.collectionView(collectionView, canMoveItemAt: indexPath, value: node._unwarp())
    }

    public func _collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndex: Int, to destinationIndex: Int, node: _Node) {
        self.collectionView(collectionView, moveItemAt: sourceIndex, to: destinationIndex, value: node._unwarp())
    }

}
