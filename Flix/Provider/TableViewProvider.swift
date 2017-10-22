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

public protocol _TableViewMultiNodeProvider {
    
    var identity: String { get }
    
    func _tap(_ tableView: UITableView, indexPath: IndexPath, node: _Node)
    
    func _genteralNodes() -> Observable<[_Node]>
    
    func _tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, node: _Node) -> CGFloat?
    
    func _configureCell(_ tableView: UITableView, indexPath: IndexPath, node: _Node) -> UITableViewCell

    func register(_ tableView: UITableView)
    
}

public protocol TableViewMultiNodeProvider: _TableViewMultiNodeProvider {

    associatedtype Value
    
    func configureCell(_ tableView: UITableView, indexPath: IndexPath, value: Value) -> UITableViewCell

    func tap(_ tableView: UITableView, indexPath: IndexPath, value: Value)
    
    func genteralValues() -> Observable<[Value]>
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, value: Value) -> CGFloat?
    
}

extension TableViewMultiNodeProvider {
    
    public func tap(_ tableView: UITableView, indexPath: IndexPath, value: Value) {
        
    }
    
    public func _configureCell(_ tableView: UITableView, indexPath: IndexPath, node: _Node) -> UITableViewCell {
        return self.configureCell(tableView, indexPath: indexPath, value: node._unwarp())
    }
    
    public func _genteralNodes() -> Observable<[_Node]> {
        let providerIdentity = self.identity
        return genteralValues()
            .map { $0.map { ValueNode(providerIdentity: providerIdentity, value: $0) } }
    }
    
    public func _tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, node: _Node) -> CGFloat? {
        return self.tableView(tableView, heightForRowAt: indexPath, value: node._unwarp())
    }
    
    public func _tap(_ tableView: UITableView, indexPath: IndexPath, node: _Node) {
        self.tap(tableView, indexPath: indexPath, value: node._unwarp())
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, value: Value) -> CGFloat? {
        return nil
    }
    
}

public protocol TableViewProvider: TableViewMultiNodeProvider {
    
    associatedtype Cell: UITableViewCell
    
    func configureCell(_ tableView: UITableView, cell: Cell, indexPath: IndexPath, value: Value)

}

extension TableViewProvider {
    
    public func configureCell(_ tableView: UITableView, indexPath: IndexPath, value: Value) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.identity, for: indexPath)
        self.configureCell(tableView, cell: cell as! Cell, indexPath: indexPath, value: value)
        return cell
    }
    
    public func register(_ tableView: UITableView) {
        tableView.register(Cell.self, forCellReuseIdentifier: self.identity)
    }
    
}

public typealias _AnimatableTableViewMultiNodeProvider = _AnimatableProviderable & _TableViewMultiNodeProvider

public protocol AnimatableTableViewMultiNodeProvider: TableViewMultiNodeProvider, _AnimatableProviderable where Value: Equatable, Value: StringIdentifiableType {
    
    func genteralAnimatableNodes() -> Observable<[IdentifiableNode]>
    
}

public typealias AnimatableTableViewProvider = AnimatableTableViewMultiNodeProvider & TableViewProvider

extension AnimatableTableViewMultiNodeProvider {
    
    public func _genteralAnimatableNodes() -> Observable<[IdentifiableNode]> {
        return genteralAnimatableNodes()
    }
    
}

extension AnimatableTableViewMultiNodeProvider {

    public func _genteralNodes() -> Observable<[_Node]> {
        let providerIdentity = self.identity
        return genteralValues()
            .map { $0.map { IdentifiableValueNode(providerIdentity: providerIdentity, value: $0) } }
    }
    
    public func genteralAnimatableNodes() -> Observable<[IdentifiableNode]> {
        let providerIdentity = self.identity
        return genteralValues()
            .map { $0.map { IdentifiableNode(node: IdentifiableValueNode(providerIdentity: providerIdentity, value: $0)) } }
    }
    
}

public typealias _UniqueAnimatableTableViewProvider = AnimatableTableViewProvider & Equatable & StringIdentifiableType

public protocol UniqueAnimatableTableViewProvider: _UniqueAnimatableTableViewProvider /* where Value == Self, Cell == UITableViewCell */ {

    func onCreate(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath)
    func onUpdate(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath)

}

extension UniqueAnimatableTableViewProvider {
    
    public func onUpdate(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {

    }

    public func configureCell(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath, value: Self) {
        if !cell.hasConfigured {
            cell.hasConfigured = true
            onCreate(tableView, cell: cell, indexPath: indexPath)
        }
        onUpdate(tableView, cell: cell, indexPath: indexPath)
    }

    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return true
    }
    
    public var providerIdentity: String {
        return self.identity
    }
    
    public func genteralValues() -> Observable<[Self]> {
        return Observable.just([self])
    }
    
}
