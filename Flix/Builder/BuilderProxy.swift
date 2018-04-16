//
//  BuilderProxy.swift
//  Flix
//
//  Created by wc on 22/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit

private var tableViewBuilderKey: Void?
private var tableViewAnimatableBuilderKey: Void?
private var collectionViewBuilderKey: Void?
private var collectionViewAnimatableBuilderKey: Void?

public struct FlixProxy<Base> {
    
    fileprivate let base: Base
    
}

public protocol FlixProxyable { }

extension FlixProxyable {

    public var flix: FlixProxy<Self> {
        return FlixProxy(base: self)
    }

}

public struct FlixAnimatableProxy<Base> {
    
    fileprivate let base: Base
    
}

extension FlixProxy {
    
    public var animatable: FlixAnimatableProxy<Base> {
        return FlixAnimatableProxy(base: self.base)
    }
    
}

private protocol _PerformGroupUpdatesable {

    associatedtype Builder: PerformGroupUpdatesable
    associatedtype AnimatableBuilder: PerformGroupUpdatesable

    var builder: Builder? { get }
    var animatableBuilder: AnimatableBuilder? { get }

}

extension _PerformGroupUpdatesable {

    fileprivate var performGroupUpdatesable: PerformGroupUpdatesable? {
        return self.builder ?? self.animatableBuilder
    }

}

extension UITableView: _PerformGroupUpdatesable {

    fileprivate var builder: TableViewBuilder? {
        get {
            return objc_getAssociatedObject(self, &tableViewBuilderKey) as? TableViewBuilder
        }
        set {
            objc_setAssociatedObject(self, &tableViewBuilderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    fileprivate var animatableBuilder: AnimatableTableViewBuilder? {
        get {
            return objc_getAssociatedObject(self, &tableViewAnimatableBuilderKey) as? AnimatableTableViewBuilder
        }
        set {
            objc_setAssociatedObject(self, &tableViewAnimatableBuilderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

}

extension UICollectionView: _PerformGroupUpdatesable {
    
    fileprivate var builder: CollectionViewBuilder? {
        get {
            return objc_getAssociatedObject(self, &collectionViewBuilderKey) as? CollectionViewBuilder
        }
        set {
            objc_setAssociatedObject(self, &collectionViewBuilderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var animatableBuilder: AnimatableCollectionViewBuilder? {
        get {
            return objc_getAssociatedObject(self, &collectionViewAnimatableBuilderKey) as? AnimatableCollectionViewBuilder
        }
        set {
            objc_setAssociatedObject(self, &collectionViewAnimatableBuilderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

extension UITableView: FlixProxyable { }
extension UICollectionView: FlixProxyable { }

extension FlixProxy where Base: UICollectionView { // ugly

    public func beginGroupUpdates() {
        self.base.performGroupUpdatesable?.beginGroupUpdates()
    }

    public func endGroupUpdates() {
        self.base.performGroupUpdatesable?.endGroupUpdates()
    }

    public func performGroupUpdates(_ updates: (() -> Void)) {
        self.beginGroupUpdates(); defer { self.endGroupUpdates() }
        updates()
    }

}

extension FlixProxy where Base: UITableView {

    public func beginGroupUpdates() {
        self.base.performGroupUpdatesable?.beginGroupUpdates()
    }

    public func endGroupUpdates() {
        self.base.performGroupUpdatesable?.endGroupUpdates()
    }

    public func performGroupUpdates(_ updates: (() -> Void)) {
        self.beginGroupUpdates(); defer { self.endGroupUpdates() }
        updates()
    }

}

extension FlixProxy where Base: UITableView {

    @discardableResult
    public func build(_ sectionProviders: [TableViewSectionProvider]) -> TableViewBuilder {
        if let builder = base.builder {
            builder.sectionProviders.accept(sectionProviders)
            return builder
        } else {
            let builder = TableViewBuilder(tableView: self.base, sectionProviders: sectionProviders)
            self.base.builder = builder
            return builder
        }
    }

    @discardableResult
    public func build(_ providers: [_TableViewMultiNodeProvider]) -> TableViewBuilder {
        if let builder = base.builder {
            builder.sectionProviders.accept([TableViewSectionProvider(providers: providers)])
            return builder
        } else {
            let builder = TableViewBuilder(tableView: self.base, providers: providers)
            self.base.builder = builder
            return builder
        }
    }
    
}

extension FlixAnimatableProxy where Base: UITableView {

    @discardableResult
    public func build(_ sectionProviders: [AnimatableTableViewSectionProvider]) -> AnimatableTableViewBuilder {
        if let builder = base.animatableBuilder {
            builder.sectionProviders.accept(sectionProviders)
            return builder
        } else {
            let animatableBuilder = AnimatableTableViewBuilder(tableView: self.base, sectionProviders: sectionProviders)
            self.base.animatableBuilder = animatableBuilder
            return animatableBuilder
        }
    }

    @discardableResult
    public func build(_ providers: [_AnimatableTableViewMultiNodeProvider]) -> AnimatableTableViewBuilder {
        if let builder = base.animatableBuilder {
            builder.sectionProviders.accept([AnimatableTableViewSectionProvider(providers: providers)])
            return builder
        } else {
            let animatableBuilder = AnimatableTableViewBuilder(tableView: self.base, providers: providers)
            self.base.animatableBuilder = animatableBuilder
            return animatableBuilder
        }
    }
    
}

extension FlixProxy where Base: UICollectionView {

    @discardableResult
    public func build(_ sectionProviders: [CollectionViewSectionProvider]) -> CollectionViewBuilder {
        if let builder = base.builder {
            builder.sectionProviders.accept(sectionProviders)
            return builder
        } else {
            let builder = CollectionViewBuilder(collectionView: self.base, sectionProviders: sectionProviders)
            self.base.builder = builder
            return builder
        }
    }

    @discardableResult
    public func build(_ providers: [_CollectionViewMultiNodeProvider]) -> CollectionViewBuilder {
        if let builder = base.builder {
            builder.sectionProviders.accept([CollectionViewSectionProvider(providers: providers)])
            return builder
        } else {
            let builder = CollectionViewBuilder(collectionView: self.base, providers: providers)
            self.base.builder = builder
            return builder
        }
    }
    
}

extension FlixAnimatableProxy where Base: UICollectionView {

    @discardableResult
    public func build(_ sectionProviders: [AnimatableCollectionViewSectionProvider]) -> AnimatableCollectionViewBuilder {
        if let builder = base.animatableBuilder {
            builder.sectionProviders.accept(sectionProviders)
            return builder
        } else {
            let animatableBuilder = AnimatableCollectionViewBuilder(collectionView: self.base, sectionProviders: sectionProviders)
            self.base.animatableBuilder = animatableBuilder
            return animatableBuilder
        }
    }

    @discardableResult
    public func build(_ providers: [_AnimatableCollectionViewMultiNodeProvider]) -> AnimatableCollectionViewBuilder {
        if let builder = base.animatableBuilder {
            builder.sectionProviders.accept([AnimatableCollectionViewSectionProvider(providers: providers)])
            return builder
        } else {
            let animatableBuilder = AnimatableCollectionViewBuilder(collectionView: self.base, providers: providers)
            self.base.animatableBuilder = animatableBuilder
            return animatableBuilder
        }
    }

}
