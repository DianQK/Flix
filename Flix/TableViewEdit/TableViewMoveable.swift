//
//  TableViewMoveable.swift
//  Flix
//
//  Created by DianQK on 20/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit

public protocol _TableViewMoveable: _TableViewEditable {

    func _tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath, node: _Node) -> Bool

    func _tableView(_ tableView: UITableView, moveRowAt sourceIndex: Int, to destinationIndex: Int, node: _Node)
    
}

public protocol TableViewMoveable: TableViewEditable, _TableViewMoveable {
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath, value: Value) -> Bool

    func tableView(_ tableView: UITableView, moveRowAt sourceIndex: Int, to destinationIndex: Int, value: Value)
   
}

extension TableViewMoveable {

    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath, value: Value) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath, value: Value) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, value: Value) -> [UITableViewRowAction]? {
        return nil
    }

}
//
//extension TableViewEditable {
//
//    public func _tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, node: _Node) -> [UITableViewRowAction]? {
//        if let valueNode = node as? ValueNode<Value> {
//            return self.tableView(tableView, editActionsForRowAt: indexPath, value: valueNode.value)
//        } else {
//            fatalError()
//        }
//    }
//
//    public func _tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath, node: _Node) -> Bool {
//        if let valueNode = node as? ValueNode<Value> {
//            return self.tableView(tableView, canEditRowAt: indexPath, value: valueNode.value)
//        } else {
//            fatalError()
//        }
//    }
//
//}
//
extension TableViewMoveable where Value: StringIdentifiableType, Value: Equatable {

    public func _tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath, node: _Node) -> Bool {
        if let valueNode = node as? IdentifiableValueNode<Value> {
            return self.tableView(tableView, canMoveRowAt: indexPath, value: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func _tableView(_ tableView: UITableView, moveRowAt sourceIndex: Int, to destinationIndex: Int, node: _Node) {
        if let valueNode = node as? IdentifiableValueNode<Value> {
            self.tableView(tableView, moveRowAt: sourceIndex, to: destinationIndex, value: valueNode.value)
        } else {
            fatalError()
        }
    }

}
//
//public protocol _TableViewDeleteable {
//
//    func _tableView(_ tableView: UITableView, itemDeletedForRowAt indexPath: IndexPath, node: _Node)
//
//}
//
//public typealias __TableViewDeleteable = _TableViewDeleteable & TableViewEditable
//
//public protocol TableViewDeleteable: __TableViewDeleteable {
//
//    func tableView(_ tableView: UITableView, itemDeletedForRowAt indexPath: IndexPath, value: Value)
//    func tableView(_ tableView: UITableView, canDeleteRowAt indexPath: IndexPath, value: Value) -> Bool
//
//}
//
//extension TableViewDeleteable {
//
//    public func _tableView(_ tableView: UITableView, itemDeletedForRowAt indexPath: IndexPath, node: _Node) {
//        if let valueNode = node as? ValueNode<Value> {
//            self.tableView(tableView, itemDeletedForRowAt: indexPath, value: valueNode.value)
//        } else {
//            fatalError()
//        }
//    }
//
//}
//
//extension TableViewDeleteable where Value: StringIdentifiableType, Value: Equatable {
//
//    public func _tableView(_ tableView: UITableView, itemDeletedForRowAt indexPath: IndexPath, node: _Node) {
//        if let valueNode = node as? IdentifiableValueNode<Value> {
//            self.tableView(tableView, itemDeletedForRowAt: indexPath, value: valueNode.value)
//        } else {
//            fatalError()
//        }
//    }
//
//}
//
//extension TableViewDeleteable {
//
//    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, value: Value) -> [UITableViewRowAction]? {
//        return nil
//    }
//
//    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath, value: Value) -> Bool {
//        return self.tableView(tableView, canDeleteRowAt: indexPath, value: value)
//    }
//
//    public func tableView(_ tableView: UITableView, canDeleteRowAt indexPath: IndexPath, value: Value) -> Bool {
//        return true
//    }
//
//}
//
