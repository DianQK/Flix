//
//  TableViewSectionProvider.swift
//  Flix
//
//  Created by DianQK on 04/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

public enum UITableElementKindSection {
    case header
    case footer
}

public protocol _SectionTableViewProvider {
    
    var identity: String { get }
    var cellType: UITableViewHeaderFooterView.Type { get }
    var tableElementKindSection: UITableElementKindSection { get }
    
    func _tableView(_ tableView: UITableView, heightInSection section: Int, node: _Node) -> CGFloat?
    func _configureSection(_ tableView: UITableView, view: UITableViewHeaderFooterView, viewInSection section: Int, node: _Node)
    
    func _genteralSection() -> Observable<_Node?>
    
}

extension _SectionTableViewProvider {
    
    public func register(_ tableView: UITableView) {
        tableView.register(self.cellType, forHeaderFooterViewReuseIdentifier: self.identity)
    }

}

public protocol SectionTableViewProvider: _SectionTableViewProvider {
    
    associatedtype Cell: UITableViewHeaderFooterView
    associatedtype Value
    
    func tableView(_ tableView: UITableView, heightInSection section: Int, value: Value) -> CGFloat?
    func configureSection(_ tableView: UITableView, view: UITableViewHeaderFooterView, viewInSection section: Int, value: Value)
    
    func genteralSection() -> Observable<Value?>
    
}

extension SectionTableViewProvider {
    
    public var cellType: UITableViewHeaderFooterView.Type { return Cell.self }
    
    public func _tableView(_ tableView: UITableView, heightInSection section: Int, node: _Node) -> CGFloat? {
        if let valueNode = node as? ValueNode<Value> {
            return self.tableView(tableView, heightInSection: section, value: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func _configureSection(_ tableView: UITableView, view: UITableViewHeaderFooterView, viewInSection section: Int, node: _Node) {
        if let valueNode = node as? ValueNode<Value> {
            self.configureSection(tableView, view: view as! Cell, viewInSection: section, value: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func _genteralSection() -> Observable<_Node?> {
        let providerIdentity = self.identity
        return genteralSection().map { $0.map { ValueNode(providerIdentity: providerIdentity, value: $0) } }
    }
    
    public func tableView(_ tableView: UITableView, heightInSection section: Int, node: _Node) -> CGFloat? {
        return nil
    }
    
}

public protocol _AnimatableSectionProviderable {
    
    func _genteralAnimatableSection() -> Observable<IdentifiableNode?>
    
}

public typealias _AnimatableSectionTableViewProvider = _AnimatableSectionProviderable & _SectionTableViewProvider

public protocol AnimatableSectionTableViewProvider: SectionTableViewProvider, _AnimatableSectionProviderable where Value: Equatable, Value: StringIdentifiableType {

    func genteralAnimatableSection() -> Observable<IdentifiableNode?>
    
}

extension AnimatableSectionTableViewProvider {
    
    public func _genteralAnimatableSection() -> Observable<IdentifiableNode?> {
        return genteralAnimatableSection()
    }
    
}

extension AnimatableSectionTableViewProvider {
    
    public func _configureSection(_ tableView: UITableView, view: UITableViewHeaderFooterView, viewInSection section: Int, node: _Node) {
        if let valueNode = node as? IdentifiableValueNode<Value> {
            self.configureSection(tableView, view: view as! Cell, viewInSection: section, value: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func _tableView(_ tableView: UITableView, heightInSection section: Int, node: _Node) -> CGFloat? {
        if let valueNode = node as? IdentifiableValueNode<Value> {
            return self.tableView(tableView, heightInSection: section, value: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func tableView(_ tableView: UITableView, heightInSection section: Int, value: Value) -> CGFloat? {
        return nil
    }
    
    public func genteralAnimatableSection() -> Observable<IdentifiableNode?> {
        let providerIdentity = self.identity
        return genteralSection()
            .map { $0.map { IdentifiableNode(node: IdentifiableValueNode(providerIdentity: providerIdentity, value: $0)) } }
    }
    
}
