//
//  TableViewDeleteable.swift
//  Flix
//
//  Created by DianQK on 22/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public protocol _TableViewDeleteable {
    
    func _tableView(_ tableView: UITableView, itemDeletedForRowAt indexPath: IndexPath, node: _Node)
    func _tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath, node: _Node) -> String?
    
}

public protocol TableViewDeleteable: _TableViewDeleteable, TableViewEditable {
    
    func tableView(_ tableView: UITableView, itemDeletedForRowAt indexPath: IndexPath, value: Value)
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath, value: Value) -> String?
    
}

extension TableViewDeleteable where Self: TableViewMultiNodeProvider {

    public func tableView(_ tableView: UITableView, itemDeletedForRowAt indexPath: IndexPath, value: Self.Value) { }
    
    public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath, value: Self.Value) -> String? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath, value: Self.Value) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    public func _tableView(_ tableView: UITableView, itemDeletedForRowAt indexPath: IndexPath, node: _Node) {
        self.tableView(tableView, itemDeletedForRowAt: indexPath, value: node._unwarp())
        self.event._itemDeleted.onNext((tableView: tableView, indexPath: indexPath, value: node._unwarp()))
    }
    
    public func _tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath, node: _Node) -> String? {
        return self.tableView(tableView, titleForDeleteConfirmationButtonForRowAt: indexPath, value: node._unwarp())
    }
    
}

extension TableViewEvent where Provider: TableViewDeleteable {

    public var modelDeleted: ControlEvent<Value> {
        return ControlEvent(events: self._itemDeleted.map { $0.value })
    }

    public var itemDeleted: ControlEvent<EventValue> {
        return ControlEvent(events: self._itemDeleted)
    }

}
