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

public class TableViewEvent<Value> {

    public typealias EventValue = (tableView: UITableView, indexPath: IndexPath, value: Value)

    public var selectedEvent: ControlEvent<()> { return ControlEvent(events: self._itemSelected.map { _ in }) }

    public var modelSelected: ControlEvent<Value> { return ControlEvent(events: self.itemSelected.map { $0.value }) }

    public var itemSelected: ControlEvent<EventValue> { return ControlEvent(events: self._itemSelected) }
    var _itemSelected = PublishSubject<EventValue>()

    public var modelDeselected: ControlEvent<Value> { return ControlEvent(events: self.itemDeselected.map { $0.value }) }

    public var itemDeselected: ControlEvent<EventValue> { return ControlEvent(events: self._itemDeselected) }
    var _itemDeselected = PublishSubject<EventValue>()

    init() { }

}
