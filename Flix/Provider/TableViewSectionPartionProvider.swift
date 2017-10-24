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

public protocol _SectionPartionTableViewProvider: FlixCustomStringConvertible {

    var cellType: UITableViewHeaderFooterView.Type { get }
    var tableElementKindSection: UITableElementKindSection { get }
    
    func _tableView(_ tableView: UITableView, heightInSection section: Int, node: _Node) -> CGFloat?
    func _configureSection(_ tableView: UITableView, view: UITableViewHeaderFooterView, viewInSection section: Int, node: _Node)
    
    func _genteralSectionPartion() -> Observable<_Node?>
    
}

extension _SectionPartionTableViewProvider {
    
    public func register(_ tableView: UITableView) {
        tableView.register(self.cellType, forHeaderFooterViewReuseIdentifier: self._flix_identity)
    }

}

public protocol SectionPartionTableViewProvider: _SectionPartionTableViewProvider {
    
    associatedtype Cell: UITableViewHeaderFooterView
    associatedtype Value
    
    func tableView(_ tableView: UITableView, heightInSection section: Int, value: Value) -> CGFloat?
    func configureSection(_ tableView: UITableView, view: UITableViewHeaderFooterView, viewInSection section: Int, value: Value)
    
    func genteralSection() -> Observable<Value?>
    
}

extension SectionPartionTableViewProvider {
    
    public var cellType: UITableViewHeaderFooterView.Type { return Cell.self }
    
    public func _configureSection(_ tableView: UITableView, view: UITableViewHeaderFooterView, viewInSection section: Int, node: _Node) {
        self.configureSection(tableView, view: view as! Cell, viewInSection: section, value: node._unwarp())
    }
    
    public func _genteralSectionPartion() -> Observable<_Node?> {
        let providerIdentity = self._flix_identity
        return genteralSection().map { $0.map { Node(providerIdentity: providerIdentity, value: $0) } }
    }
    
    public func _tableView(_ tableView: UITableView, heightInSection section: Int, node: _Node) -> CGFloat? {
        return self.tableView(tableView, heightInSection: section, value: node._unwarp())
    }
    
    public func tableView(_ tableView: UITableView, heightInSection section: Int, node: _Node) -> CGFloat? {
        return nil
    }
    
}

public protocol _AnimatableSectionPartionProviderable {
    
    func _genteralAnimatableSectionPartion() -> Observable<IdentifiableNode?>
    
}

public typealias _AnimatableSectionPartionTableViewProvider = _AnimatableSectionPartionProviderable & _SectionPartionTableViewProvider

public protocol AnimatablePartionSectionTableViewProvider: SectionPartionTableViewProvider, _AnimatableSectionPartionProviderable where Value: Equatable, Value: StringIdentifiableType {

    func genteralAnimatableSectionPartion() -> Observable<IdentifiableNode?>
    
}

extension AnimatablePartionSectionTableViewProvider {
    
    public func _genteralAnimatableSectionPartion() -> Observable<IdentifiableNode?> {
        return genteralAnimatableSectionPartion()
    }

    public var identity: String {
        return self._flix_identity
    }
    
}

extension AnimatablePartionSectionTableViewProvider {
    
    public func genteralAnimatableSectionPartion() -> Observable<IdentifiableNode?> {
        let providerIdentity = self._flix_identity
        return genteralSection().map { $0.map { IdentifiableNode(providerIdentity: providerIdentity, valueNode: $0) } }
    }
    
}
