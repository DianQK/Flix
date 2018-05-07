//
//  TableViewProvider.swift
//  Flix
//
//  Created by DianQK on 03/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

public protocol _TableViewMultiNodeProvider: FlixCustomStringConvertible {

    func _itemSelected(_ tableView: UITableView, indexPath: IndexPath, node: _Node)

    func _itemDeselected(_ tableView: UITableView, indexPath: IndexPath, node: _Node)
    
    func _tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, node: _Node) -> CGFloat?
    
    func _configureCell(_ tableView: UITableView, indexPath: IndexPath, node: _Node) -> UITableViewCell

    func _register(_ tableView: UITableView)
    
    func _createNodes() -> Observable<[Node]>

}

private var _tableViewKey: Void?

extension _TableViewMultiNodeProvider {

    var __providers: [_TableViewMultiNodeProvider] {
        if let groupProvider = self as? _TableViewGroupProvider {
            return groupProvider._providers
        } else {
            return [self]
        }
    }

    public fileprivate(set) var tableView: UITableView? {
        get {
            return objc_getAssociatedObject(self, &_tableViewKey) as? UITableView
        }
        set {
            objc_setAssociatedObject(self, &_tableViewKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    public func _register(_ tableView: UITableView) { }

}

public protocol TableViewMultiNodeProvider: _TableViewMultiNodeProvider, ReactiveCompatible {

    associatedtype Value
    
    func configureCell(_ tableView: UITableView, indexPath: IndexPath, value: Value) -> UITableViewCell

    func itemSelected(_ tableView: UITableView, indexPath: IndexPath, value: Value)

    func itemDeselected(_ tableView: UITableView, indexPath: IndexPath, value: Value)
    
    func createValues() -> Observable<[Value]>
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, value: Value) -> CGFloat?

    func register(_ tableView: UITableView)
    
}

extension TableViewMultiNodeProvider {

    public func _register(_ tableView: UITableView) {
        self.register(tableView)
        self.tableView = tableView
    }

    public func itemSelected(_ tableView: UITableView, indexPath: IndexPath, value: Value) { }

    public func itemDeselected(_ tableView: UITableView, indexPath: IndexPath, value: Value) { }
    
    public func _createNodes() -> Observable<[Node]> {
        let providerIdentity = self._flix_identity
        return createValues()
            .map { $0.map { Node(providerIdentity: providerIdentity, value: $0) } }
    }
    
    public func _configureCell(_ tableView: UITableView, indexPath: IndexPath, node: _Node) -> UITableViewCell {
        return self.configureCell(tableView, indexPath: indexPath, value: node._unwarp())
    }
    
    public func _tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, node: _Node) -> CGFloat? {
        return self.tableView(tableView, heightForRowAt: indexPath, value: node._unwarp())
    }

    public func _itemSelected(_ tableView: UITableView, indexPath: IndexPath, node: _Node) {
        self.itemSelected(tableView, indexPath: indexPath, value: node._unwarp())
        self.event._itemSelected.onNext((tableView: tableView, indexPath: indexPath, value: node._unwarp()))
    }

    public func _itemDeselected(_ tableView: UITableView, indexPath: IndexPath, node: _Node) {
        self.itemDeselected(tableView, indexPath: indexPath, value: node._unwarp())
        self.event._itemDeselected.onNext((tableView: tableView, indexPath: indexPath, value: node._unwarp()))
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, value: Value) -> CGFloat? {
        return nil
    }
    
}

private var providerEventKey: Void?

extension TableViewMultiNodeProvider {

    public var event: TableViewEvent<Self> {
        if let event = objc_getAssociatedObject(self, &providerEventKey) as? TableViewEvent<Self> {
            return event
        } else {
            let event = TableViewEvent<Self>()
            objc_setAssociatedObject(self, &providerEventKey, event, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return event
        }
    }

}

public protocol TableViewProvider: TableViewMultiNodeProvider {
    
    associatedtype Cell: UITableViewCell
    
    func configureCell(_ tableView: UITableView, cell: Cell, indexPath: IndexPath, value: Value)

}

extension TableViewProvider {
    
    public func configureCell(_ tableView: UITableView, indexPath: IndexPath, value: Value) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self._flix_identity, for: indexPath) as! Cell
        self.configureCell(tableView, cell: cell, indexPath: indexPath, value: value)
        return cell
    }
    
    public func register(_ tableView: UITableView) {
        tableView.register(Cell.self, forCellReuseIdentifier: self._flix_identity)
    }
    
}

public typealias _AnimatableTableViewMultiNodeProvider = _AnimatableProviderable & _TableViewMultiNodeProvider

public protocol AnimatableTableViewMultiNodeProvider: TableViewMultiNodeProvider, _AnimatableProviderable where Value: Equatable, Value: StringIdentifiableType {
    
    func createAnimatableNodes() -> Observable<[IdentifiableNode]>

}

public typealias AnimatableTableViewProvider = AnimatableTableViewMultiNodeProvider & TableViewProvider

extension AnimatableTableViewMultiNodeProvider {
    
    public func _createAnimatableNodes() -> Observable<[IdentifiableNode]> {
        return createAnimatableNodes()
    }
    
}

extension AnimatableTableViewMultiNodeProvider {
    
    public func createAnimatableNodes() -> Observable<[IdentifiableNode]> {
        let providerIdentity = self._flix_identity
        return createValues()
            .map { $0.map { IdentifiableNode(providerIdentity: providerIdentity, valueNode: $0) } }
    }
    
}

public protocol UniqueAnimatableTableViewProvider: AnimatableTableViewProvider, Equatable, StringIdentifiableType {

    func onCreate(_ tableView: UITableView, cell: Cell, indexPath: IndexPath)
    func onUpdate(_ tableView: UITableView, cell: Cell, indexPath: IndexPath)

}

extension UniqueAnimatableTableViewProvider {
    
    public func onUpdate(_ tableView: UITableView, cell: Cell, indexPath: IndexPath) {

    }

    public func configureCell(_ tableView: UITableView, cell: Cell, indexPath: IndexPath, value: Self) {
        if !cell.hasConfigured {
            cell.hasConfigured = true
            onCreate(tableView, cell: cell, indexPath: indexPath)
        }
        onUpdate(tableView, cell: cell, indexPath: indexPath)
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return true
    }
    
    public var identity: String {
        return self._flix_identity
    }
    
    public var providerIdentity: String {
        return self.identity
    }
    
    public func createValues() -> Observable<[Self]> {
        return Observable.just([self])
    }
    
}

extension UniqueAnimatableTableViewProvider where Self: CustomProvider {

    public func configureCell(_ tableView: UITableView, indexPath: IndexPath, value: Value) -> UITableViewCell {
        let cell: Cell = self.cell ?? (tableView.dequeueReusableCell(withIdentifier: self._flix_identity, for: indexPath) as! Cell)
        self.configureCell(tableView, cell: cell, indexPath: indexPath, value: value)
        return cell
    }

}
