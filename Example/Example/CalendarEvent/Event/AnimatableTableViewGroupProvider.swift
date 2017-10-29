//
//  AnimatableTableViewGroupProvider.swift
//  Example
//
//  Created by wc on 28/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

public protocol AnimatableTableViewGroupProvider: AnimatableTableViewMultiNodeProvider {

    var providers: [_AnimatableTableViewMultiNodeProvider] { get } // return all providers

    func genteralAnimatableProviders() -> Observable<[_AnimatableTableViewMultiNodeProvider]>

}

extension AnimatableTableViewGroupProvider {

    public func register(_ tableView: UITableView) { // Maybe we should move this to _TableViewMultiNodeProvider
        for provider in providers {
            provider.register(tableView)
        }
    }

    public var _providers: [_TableViewMultiNodeProvider] {
        return self.providers
    }

    public func genteralAnimatableNodes() -> Observable<[IdentifiableNode]> {
        return genteralAnimatableProviders().map { $0.map { $0._genteralAnimatableNodes() } }
            .flatMapLatest { Observable.combineLatest($0) { $0.flatMap { $0 } } }
    }

}
