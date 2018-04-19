//
//  TableViewEvent.swift
//  Flix
//
//  Created by DianQK on 2018/4/18.
//  Copyright © 2018 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class TableViewEvent<Provider: TableViewMultiNodeProvider> {

    public typealias Value = Provider.Value

    public typealias EventValue = (tableView: UITableView, indexPath: IndexPath, value: Value)

    public var selectedEvent: ControlEvent<()> { return ControlEvent(events: self._itemSelected.map { _ in }) }

    public var modelSelected: ControlEvent<Value> { return ControlEvent(events: self.itemSelected.map { $0.value }) }

    public var itemSelected: ControlEvent<EventValue> { return ControlEvent(events: self._itemSelected) }
    private(set) lazy var _itemSelected = PublishSubject<EventValue>()

    public var modelDeselected: ControlEvent<Value> { return ControlEvent(events: self.itemDeselected.map { $0.value }) }

    public var itemDeselected: ControlEvent<EventValue> { return ControlEvent(events: self._itemDeselected) }
    private(set) lazy var _itemDeselected = PublishSubject<EventValue>()

    public typealias MoveEventValue = (tableView: UITableView, sourceIndex: Int, destinationIndex: Int, value: Value)
    private(set) lazy var _moveItem = PublishSubject<MoveEventValue>()

    private(set) lazy var _itemDeleted = PublishSubject<EventValue>()

    private(set) lazy var _itemInserted = PublishSubject<EventValue>()

    init() { }

}
