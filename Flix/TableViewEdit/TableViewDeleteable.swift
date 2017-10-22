//
//  TableViewDeleteable.swift
//  Flix
//
//  Created by DianQK on 22/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit

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
        self.tableView(tableView, itemDeletedForRowAt: indexPath, value: node._unwarp())
    }
    
    public func _tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath, node: _Node) -> String? {
        return self.tableView(tableView, titleForDeleteConfirmationButtonForRowAt: indexPath, value: node._unwarp())
    }
    
}
