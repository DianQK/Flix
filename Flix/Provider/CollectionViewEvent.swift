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

public class CollectionViewEvent<Value> {

    public typealias EventValue = (collectionView: UICollectionView, indexPath: IndexPath, value: Value)

    public var modelSelected: ControlEvent<Value> { return ControlEvent(events: self.itemSelected.map { $0.value }) }

    public var itemSelected: ControlEvent<EventValue> { return ControlEvent(events: self._itemSelected) }
    var _itemSelected = PublishSubject<EventValue>()

    public var modelDeselected: ControlEvent<Value> { return ControlEvent(events: self.itemDeselected.map { $0.value }) }

    public var itemDeselected: ControlEvent<EventValue> { return ControlEvent(events: self._itemDeselected) }
    var _itemDeselected = PublishSubject<EventValue>()

    init() { }

}
