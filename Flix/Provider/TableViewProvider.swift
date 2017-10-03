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

public protocol _TableViewProvider {
    
    var identity: String { get }
    var cellType: UITableViewCell.Type { get }
    
    func _configureCell(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath, node: _Node)
    
    func _tap(_ tableView: UITableView, indexPath: IndexPath, node: _Node)
    
    func _genteralNodes() -> Observable<[_Node]>
    
    func _tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, node: _Node) -> CGFloat?

}

extension _TableViewProvider {
    
    public func register(_ tableView: UITableView) {
        tableView.register(self.cellType, forCellReuseIdentifier: self.identity)
    }
    
}

public protocol TableViewProvider: _TableViewProvider {
    
    associatedtype CellType: UITableViewCell
    associatedtype ValueType
    
    func configureCell(_ tableView: UITableView, cell: CellType, indexPath: IndexPath, node: ValueType)
    func tap(_ tableView: UITableView, indexPath: IndexPath, node: ValueType)
    
    func genteralNodes() -> Observable<[ValueType]>
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, node: ValueType) -> CGFloat?
    
}

extension TableViewProvider {
    
    public var cellType: UITableViewCell.Type { return CellType.self }
    
    public func _configureCell(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath, node: _Node) {
        if let valueNode = node as? ValueNode<ValueType> {
            configureCell(tableView, cell: cell as! CellType, indexPath: indexPath, node: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func _tap(_ tableView: UITableView, indexPath: IndexPath, node: _Node) {
        if let valueNode = node as? ValueNode<ValueType> {
            tap(tableView, indexPath: indexPath, node: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func _genteralNodes() -> Observable<[_Node]> {
        let providerIdentity = self.identity
        return genteralNodes()
            .map { $0.map { ValueNode(providerIdentity: providerIdentity, value: $0) } }
    }
    
    public func _tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, node: _Node) -> CGFloat? {
        if let valueNode = node as? ValueNode<ValueType> {
            return self.tableView(tableView, heightForRowAt: indexPath, node: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, node: ValueType) -> CGFloat? {
        return nil
    }
    
}

public typealias _AnimatableTableViewProvider = _AnimatableProviderable & _TableViewProvider

public protocol AnimatableTableViewProvider: TableViewProvider, _AnimatableProviderable where ValueType: Equatable, ValueType: StringIdentifiableType {
    
    func genteralAnimatableNodes() -> Observable<[IdentifiableNode]>
    
}

extension AnimatableTableViewProvider {
    
    public func _genteralAnimatableNodes() -> Observable<[IdentifiableNode]> {
        return genteralAnimatableNodes()
    }
    
}

extension AnimatableTableViewProvider {
    
    public func _configureCell(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath, node: _Node) {
        if let valueNode = node as? IdentifiableValueNode<ValueType> {
            configureCell(tableView, cell: cell as! CellType, indexPath: indexPath, node: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func _tap(_ tableView: UITableView, indexPath: IndexPath, node: _Node) {
        if let valueNode = node as? IdentifiableValueNode<ValueType> {
            tap(tableView, indexPath: indexPath, node: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func _tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, node: _Node) -> CGFloat? {
        if let valueNode = node as? IdentifiableValueNode<ValueType> {
            return self.tableView(tableView, heightForRowAt: indexPath, node: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func genteralAnimatableNodes() -> Observable<[IdentifiableNode]> {
        let providerIdentity = self.identity
        return genteralNodes()
            .map { $0.map { IdentifiableNode(node: IdentifiableValueNode(providerIdentity: providerIdentity, value: $0)) } }
    }
    
}

public typealias _UniqueAnimatableTableViewProvider = AnimatableTableViewProvider & Equatable & StringIdentifiableType

public protocol UniqueAnimatableTableViewProvider: _UniqueAnimatableTableViewProvider where ValueType == Self {
    
    typealias CellType = UITableViewCell
    
    func onCreate(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath)
    func onUpdate(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath)
    
}

extension UniqueAnimatableTableViewProvider {
    
    public func onUpdate(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {

    }
    
    public func configureCell(_ tableView: UITableView, cell: CellType, indexPath: IndexPath, node: ValueType) {
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
    
    public func genteralNodes() -> Observable<[Self]> {
        return Observable.just([self])
    }
    
}

