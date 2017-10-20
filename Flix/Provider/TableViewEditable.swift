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
    func _tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath, node: _Node) -> UITableViewCellEditingStyle
    
}

public protocol TableViewEditable: _TableViewEditable {
    
    associatedtype Value
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, value: Value) -> [UITableViewRowAction]?
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath, value: Value) -> Bool
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath, value: Value) -> UITableViewCellEditingStyle

}

extension TableViewEditable {
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath, value: Value) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, value: Value) -> [UITableViewRowAction]? {
        return nil
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
    
    public func _tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath, node: _Node) -> UITableViewCellEditingStyle {
        if let valueNode = node as? ValueNode<Value> {
            return self.tableView(tableView, editingStyleForRowAt: indexPath, value: valueNode.value)
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
    
    public func _tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath, node: _Node) -> UITableViewCellEditingStyle {
        if let valueNode = node as? IdentifiableValueNode<Value> {
            return self.tableView(tableView, editingStyleForRowAt: indexPath, value: valueNode.value)
        } else {
            fatalError()
        }
    }

}

public protocol _TableViewDeleteable {

    func _tableView(_ tableView: UITableView, itemDeletedForRowAt indexPath: IndexPath, node: _Node)
    func _tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath, node: _Node) -> String?

}

public protocol TableViewDeleteable: _TableViewDeleteable, TableViewEditable {

    func tableView(_ tableView: UITableView, itemDeletedForRowAt indexPath: IndexPath, value: Value)
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath, value: Value) -> String?

}

extension TableViewDeleteable {
    
    public func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath, value: Value) -> String? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath, value: Value) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }

}

extension TableViewDeleteable {
    
    public func _tableView(_ tableView: UITableView, itemDeletedForRowAt indexPath: IndexPath, node: _Node) {
        if let valueNode = node as? ValueNode<Value> {
            self.tableView(tableView, itemDeletedForRowAt: indexPath, value: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func _tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath, node: _Node) -> String? {
        if let valueNode = node as? ValueNode<Value> {
            return self.tableView(tableView, titleForDeleteConfirmationButtonForRowAt: indexPath, value: valueNode.value)
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
    
    public func _tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath, node: _Node) -> String? {
        if let valueNode = node as? IdentifiableValueNode<Value> {
            return self.tableView(tableView, titleForDeleteConfirmationButtonForRowAt: indexPath, value: valueNode.value)
        } else {
            fatalError()
        }
    }

}
