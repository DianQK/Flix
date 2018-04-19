//
//  CollectionViewEvent.swift
//  Flix
//
//  Created by DianQK on 2018/4/17.
//  Copyright © 2018 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class CollectionViewEvent<Provider: CollectionViewMultiNodeProvider> {

    public typealias Value = Provider.Value

    public typealias EventValue = (collectionView: UICollectionView, indexPath: IndexPath, value: Value)

    public var selectedEvent: ControlEvent<()> { return ControlEvent(events: self._itemSelected.map { _ in }) }

    public var modelSelected: ControlEvent<Value> { return ControlEvent(events: self.itemSelected.map { $0.value }) }

    public var itemSelected: ControlEvent<EventValue> { return ControlEvent(events: self._itemSelected) }
    private(set) lazy var _itemSelected = PublishSubject<EventValue>()

    public var modelDeselected: ControlEvent<Value> { return ControlEvent(events: self.itemDeselected.map { $0.value }) }

    public var itemDeselected: ControlEvent<EventValue> { return ControlEvent(events: self._itemDeselected) }
    private(set) lazy var _itemDeselected = PublishSubject<EventValue>()

    public typealias MoveEventValue = (collectionView: UICollectionView, sourceIndex: Int, destinationIndex: Int, value: Value)
    private(set) lazy var _moveItem = PublishSubject<MoveEventValue>()

    init() { }

}
