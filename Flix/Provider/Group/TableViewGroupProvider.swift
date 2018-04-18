//
//  TableViewGroupProvider.swift
//  Flix
//
//  Created by DianQK on 30/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public protocol _TableViewGroupProvider {

    var _providers: [_TableViewMultiNodeProvider] { get }

    func createProviders() -> Observable<[_TableViewMultiNodeProvider]>

}

extension _TableViewGroupProvider where Self: _TableViewMultiNodeProvider {

    public func _itemSelected(_ tableView: UITableView, indexPath: IndexPath, node: _Node) {
        fatalError("group provider is abstract provider, you should never call this methods.")
    }

    public func _itemDeselected(_ tableView: UITableView, indexPath: IndexPath, node: _Node) {
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
            provider._register(tableView)
        }
    }

    public func _createNodes() -> Observable<[Node]> {
        return createProviders().map { $0.map { $0._createNodes() } }
            .flatMapLatest { Observable.combineLatest($0) { $0.flatMap { $0 } } }
    }

}

public protocol TableViewGroupProvider: _TableViewMultiNodeProvider, _TableViewGroupProvider {

    var providers: [_TableViewMultiNodeProvider] { get }

}

extension TableViewGroupProvider {

    public var _providers: [_TableViewMultiNodeProvider] {
        return self.providers.flatMap { (provider) -> [_TableViewMultiNodeProvider] in
            if let provider = provider as? _TableViewGroupProvider {
                return provider._providers
            } else {
                return [provider]
            }
        }
    }

}

