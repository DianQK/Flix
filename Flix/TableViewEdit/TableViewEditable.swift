//
//  TableViewEditable.swift
//  Flix
//
//  Created by DianQK on 07/10/2017.
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

extension TableViewEditable where Self: TableViewMultiNodeProvider {
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath, value: Self.Value) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, value: Self.Value) -> [UITableViewRowAction]? {
        return nil
    }
    
    public func _tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, node: _Node) -> [UITableViewRowAction]? {
        return self.tableView(tableView, editActionsForRowAt: indexPath, value: node._unwarp())
    }
    
    public func _tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath, node: _Node) -> Bool {
        return self.tableView(tableView, canEditRowAt: indexPath, value: node._unwarp())
    }
    
    public func _tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath, node: _Node) -> UITableViewCellEditingStyle {
        return self.tableView(tableView, editingStyleForRowAt: indexPath, value: node._unwarp())
    }

}
