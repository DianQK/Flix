//
//  TableViewInsertable.swift
//  Flix
//
//  Created by DianQK on 21/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public protocol _TableViewInsertable {
    
    func _tableView(_ tableView: UITableView, itemInsertedForRowAt indexPath: IndexPath, node: _Node)
    
}

public protocol TableViewInsertable: _TableViewInsertable, TableViewEditable {
    
    func tableView(_ tableView: UITableView, itemInsertedForRowAt indexPath: IndexPath, value: Value)
    
}

extension TableViewInsertable where Self: TableViewMultiNodeProvider {

    public func tableView(_ tableView: UITableView, itemInsertedForRowAt indexPath: IndexPath, value: Self.Value) { }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath, value: Self.Value) -> UITableViewCellEditingStyle {
        return .insert
    }
    
    public func _tableView(_ tableView: UITableView, itemInsertedForRowAt indexPath: IndexPath, node: _Node) {
        self.tableView(tableView, itemInsertedForRowAt: indexPath, value: node._unwarp())
        self.event._itemInserted.onNext((tableView: tableView, indexPath: indexPath, value: node._unwarp()))
    }
    
}

extension TableViewEvent where Provider: TableViewInsertable {

    public var modelInserted: ControlEvent<Value> { return ControlEvent(events: self._itemInserted.map { $0.value }) }

    public var itemInserted: ControlEvent<EventValue> {
        return ControlEvent(events: self._itemInserted)
    }

}
