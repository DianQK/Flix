//
//  TableViewMoveable.swift
//  Flix
//
//  Created by DianQK on 20/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public protocol _TableViewMoveable: _TableViewEditable {

    func _tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath, node: _Node) -> Bool

    func _tableView(_ tableView: UITableView, moveRowAt sourceIndex: Int, to destinationIndex: Int, node: _Node)
    
}

public protocol TableViewMoveable: TableViewEditable, _TableViewMoveable {
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath, value: Value) -> Bool

    func tableView(_ tableView: UITableView, moveRowAt sourceIndex: Int, to destinationIndex: Int, value: Value)
   
}

extension TableViewMoveable where Self: TableViewMultiNodeProvider {

    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath, value: Self.Value) -> Bool {
        return true
    }

    public func tableView(_ tableView: UITableView, moveRowAt sourceIndex: Int, to destinationIndex: Int, value: Self.Value) { }

    public func _tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath, node: _Node) -> Bool {
        return self.tableView(tableView, canMoveRowAt: indexPath, value: node._unwarp())
    }
    
    public func _tableView(_ tableView: UITableView, moveRowAt sourceIndex: Int, to destinationIndex: Int, node: _Node) {
        self.tableView(tableView, moveRowAt: sourceIndex, to: destinationIndex, value: node._unwarp())
        self.event._moveItem.onNext((tableView: tableView, sourceIndex: sourceIndex, destinationIndex: destinationIndex, value: node._unwarp()))
    }

}

extension TableViewEvent where Provider: TableViewMoveable {

    public var moveItem: ControlEvent<MoveEventValue> {
        return ControlEvent(events: self._moveItem)
    }

}
