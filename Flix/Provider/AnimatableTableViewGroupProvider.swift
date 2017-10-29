//
//  AnimatableTableViewGroupProvider.swift
//  Flix
//
//  Created by wc on 29/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public struct AbstractNode: StringIdentifiableType, Equatable {

    public static func ==(lhs: AbstractNode, rhs: AbstractNode) -> Bool {
        return true
    }

    public var identity: String {
        return ""
    }

}

public protocol AnimatableTableViewGroupProvider: AnimatableTableViewMultiNodeProvider where Value == AbstractNode {

    var providers: [_AnimatableTableViewMultiNodeProvider] { get }

    func genteralAnimatableProviders() -> Observable<[_AnimatableTableViewMultiNodeProvider]>

}

extension AnimatableTableViewGroupProvider {

    public func genteralValues() -> Observable<[AbstractNode]> {
        fatalError("group provider is abstract provider, you should never call this methods.")
    }

    public func configureCell(_ tableView: UITableView, indexPath: IndexPath, value: AbstractNode) -> UITableViewCell {
        fatalError("group provider is abstract provider, you should never call this methods.")
    }

    public func register(_ tableView: UITableView) { // Maybe we should move this to _TableViewMultiNodeProvider
        for provider in providers {
            provider.register(tableView)
        }
    }

    public var _providers: [_TableViewMultiNodeProvider] {
        return self.providers
    }

    public func _genteralNodes() -> Observable<[Node]> {
        return genteralAnimatableProviders().map { $0.map { $0._genteralNodes() } }
            .flatMapLatest { Observable.combineLatest($0) { $0.flatMap { $0 } } }
    }

    public func genteralAnimatableNodes() -> Observable<[IdentifiableNode]> {
        return genteralAnimatableProviders().map { $0.map { $0._genteralAnimatableNodes() } }
            .flatMapLatest { Observable.combineLatest($0) { $0.flatMap { $0 } } }
    }

}

