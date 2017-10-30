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

public protocol AnimatableTableViewGroupProvider: _AnimatableTableViewMultiNodeProvider, _TableViewGroupProvider {

    var providers: [_AnimatableTableViewMultiNodeProvider] { get }

    func genteralAnimatableProviders() -> Observable<[_AnimatableTableViewMultiNodeProvider]>

}

extension AnimatableTableViewGroupProvider {

    public func _tap(_ tableView: UITableView, indexPath: IndexPath, node: _Node) {
        fatalError("group provider is abstract provider, you should never call this methods.")
    }

    public func _tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, node: _Node) -> CGFloat? {
        fatalError("group provider is abstract provider, you should never call this methods.")
    }

    public func _configureCell(_ tableView: UITableView, indexPath: IndexPath, node: _Node) -> UITableViewCell {
        fatalError("group provider is abstract provider, you should never call this methods.")
    }

    public func register(_ tableView: UITableView) {
        for provider in __providers {
            provider.register(tableView)
        }
    }

    public var _providers: [_TableViewMultiNodeProvider] {
        return self.providers.flatMap { (provider) -> [_TableViewMultiNodeProvider] in
            if let provider = provider as? _TableViewGroupProvider {
                return provider._providers
            } else {
                return [provider]
            }
        }
    }

    public func _genteralNodes() -> Observable<[Node]> {
        return genteralProviders().map { $0.map { $0._genteralNodes() } }
            .flatMapLatest { Observable.combineLatest($0) { $0.flatMap { $0 } } }
    }

    public func genteralProviders() -> Observable<[_TableViewMultiNodeProvider]> {
        return self.genteralAnimatableProviders().map { $0 as [_TableViewMultiNodeProvider] }
    }

    public func _genteralAnimatableNodes() -> Observable<[IdentifiableNode]> {
        return genteralAnimatableProviders().map { $0.map { $0._genteralAnimatableNodes() } }
            .flatMapLatest { Observable.combineLatest($0) { $0.flatMap { $0 } } }
    }

}
