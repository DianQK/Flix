//
//  TableViewEditable.swift
//  Flix
//
//  Created by wc on 07/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit

public protocol _TableViewEditable {
    
    func _tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, node: _Node) -> [UITableViewRowAction]?
    
    func _tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath, node: _Node) -> Bool
    
}

public protocol TableViewEditable: _TableViewEditable {
    
    associatedtype Value
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, value: Value) -> [UITableViewRowAction]?
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath, value: Value) -> Bool
    
}

extension TableViewEditable {
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath, value: Value) -> Bool {
        return true
    }
    
}

extension TableViewEditable {
    
    public func _tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, node: _Node) -> [UITableViewRowAction]? {
        if let valueNode = node as? ValueNode<Value> {
            return self.tableView(tableView, editActionsForRowAt: indexPath, value: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func _tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath, node: _Node) -> Bool {
        if let valueNode = node as? ValueNode<Value> {
            return self.tableView(tableView, canEditRowAt: indexPath, value: valueNode.value)
        } else {
            fatalError()
        }
    }
    
}

extension TableViewEditable where Value: StringIdentifiableType, Value: Equatable {
    
    public func _tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, node: _Node) -> [UITableViewRowAction]? {
        if let valueNode = node as? IdentifiableValueNode<Value> {
            return self.tableView(tableView, editActionsForRowAt: indexPath, value: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func _tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath, node: _Node) -> Bool {
        if let valueNode = node as? IdentifiableValueNode<Value> {
            return self.tableView(tableView, canEditRowAt: indexPath, value: valueNode.value)
        } else {
            fatalError()
        }
    }
    
}

public protocol _TableViewDeleteable {
    
    func _tableView(_ tableView: UITableView, itemDeletedForRowAt indexPath: IndexPath, node: _Node)
    
}

public typealias __TableViewDeleteable = _TableViewDeleteable & TableViewEditable

public protocol TableViewDeleteable: __TableViewDeleteable {
    
    func tableView(_ tableView: UITableView, itemDeletedForRowAt indexPath: IndexPath, value: Value)
    func tableView(_ tableView: UITableView, canDeleteRowAt indexPath: IndexPath, value: Value) -> Bool
    
}

extension TableViewDeleteable {
    
    public func _tableView(_ tableView: UITableView, itemDeletedForRowAt indexPath: IndexPath, node: _Node) {
        if let valueNode = node as? ValueNode<Value> {
            self.tableView(tableView, itemDeletedForRowAt: indexPath, value: valueNode.value)
        } else {
            fatalError()
        }
    }
    
}

extension TableViewDeleteable where Value: StringIdentifiableType, Value: Equatable {
    
    public func _tableView(_ tableView: UITableView, itemDeletedForRowAt indexPath: IndexPath, node: _Node) {
        if let valueNode = node as? IdentifiableValueNode<Value> {
            self.tableView(tableView, itemDeletedForRowAt: indexPath, value: valueNode.value)
        } else {
            fatalError()
        }
    }
    
}

extension TableViewDeleteable {
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, value: Value) -> [UITableViewRowAction]? {
        return nil
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath, value: Value) -> Bool {
        return self.tableView(tableView, canDeleteRowAt: indexPath, value: value)
    }
    
    public func tableView(_ tableView: UITableView, canDeleteRowAt indexPath: IndexPath, value: Value) -> Bool {
        return true
    }

}
