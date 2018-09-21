//
//  TableViewSwipeable.swift
//  Flix
//
//  Created by DianQK on 2018/5/12.
//  Copyright © 2018 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@available(iOS 11.0, *)
public protocol _TableViewSwipeable {

    func _tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath, node: _Node) -> UISwipeActionsConfiguration?
    func _tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath, node: _Node) -> UISwipeActionsConfiguration?

}

@available(iOS 11.0, *)
public protocol TableViewSwipeable: TableViewEditable, _TableViewSwipeable {

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath, value: Value) -> UISwipeActionsConfiguration?
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath, value: Value) -> UISwipeActionsConfiguration?

}

@available(iOS 11.0, *)
extension TableViewSwipeable where Self: TableViewMultiNodeProvider {

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath, value: Self.Value) -> UITableViewCell.EditingStyle {
        return .none
    }

    public func _tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath, node: _Node) -> UISwipeActionsConfiguration? {
        return self.tableView(tableView, leadingSwipeActionsConfigurationForRowAt: indexPath, value: node._unwarp())
    }

    public func _tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath, node: _Node) -> UISwipeActionsConfiguration? {
        return self.tableView(tableView, trailingSwipeActionsConfigurationForRowAt: indexPath, value: node._unwarp())
    }

    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath, value: Self.Value) -> UISwipeActionsConfiguration? {
        return nil
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath, value: Self.Value) -> UISwipeActionsConfiguration? {
        return nil
    }

}
