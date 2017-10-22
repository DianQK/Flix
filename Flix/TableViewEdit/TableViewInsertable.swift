//
//  TableViewInsertable.swift
//  Flix
//
//  Created by DianQK on 21/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit

public protocol _TableViewInsertable {
    
    func _tableView(_ tableView: UITableView, itemInsertedForRowAt indexPath: IndexPath, node: _Node)
    
}

public typealias __TableViewInsertable = _TableViewInsertable & TableViewEditable

public protocol TableViewInsertable: __TableViewInsertable {
    
    func tableView(_ tableView: UITableView, itemInsertedForRowAt indexPath: IndexPath, value: Value)
    
}

extension TableViewInsertable {
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath, value: Value) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.insert
    }
    
}

extension TableViewInsertable {
    
    public func _tableView(_ tableView: UITableView, itemInsertedForRowAt indexPath: IndexPath, node: _Node) {
        self.tableView(tableView, itemInsertedForRowAt: indexPath, value: node._unwarp())
    }
    
}
