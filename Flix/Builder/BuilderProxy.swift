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

extension UITableView: FlixProxyable {
    
    fileprivate var builder: TableViewBuilder? {
        get {
            return objc_getAssociatedObject(self, &tableViewBuilderKey) as? TableViewBuilder
        }
        
        set {
            objc_setAssociatedObject(self,
                                     &tableViewBuilderKey, newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var animatableBuilder: AnimatableTableViewBuilder? {
        get {
            return objc_getAssociatedObject(self, &tableViewAnimatableBuilderKey) as? AnimatableTableViewBuilder
        }
        
        set {
            objc_setAssociatedObject(self,
                                     &tableViewAnimatableBuilderKey, newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

extension UICollectionView: FlixProxyable {
    
    fileprivate var builder: CollectionViewBuilder? {
        get {
            return objc_getAssociatedObject(self, &collectionViewBuilderKey) as? CollectionViewBuilder
        }
        
        set {
            objc_setAssociatedObject(self,
                                     &collectionViewBuilderKey, newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    fileprivate var animatableBuilder: AnimatableCollectionViewBuilder? {
        get {
            return objc_getAssociatedObject(self, &collectionViewAnimatableBuilderKey) as? AnimatableCollectionViewBuilder
        }
        
        set {
            objc_setAssociatedObject(self,
                                     &collectionViewAnimatableBuilderKey, newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

extension FlixProxy where Base: UITableView {
    
    public func build(_ sectionProviders: [TableViewSectionProvider]) {
        if let builder = base.builder {
            builder.sectionProviders.accept(sectionProviders)
        } else {
            self.base.builder = TableViewBuilder(tableView: self.base, sectionProviders: sectionProviders)
        }
    }
    
    public func build(_ providers: [_TableViewMultiNodeProvider]) {
        if let builder = base.builder {
            builder.sectionProviders.accept([TableViewSectionProvider(providers: providers)])
        } else {
            self.base.builder = TableViewBuilder(tableView: self.base, providers: providers)
        }
    }
    
}

extension FlixAnimatableProxy where Base: UITableView {
    
    public func build(_ sectionProviders: [AnimatableTableViewSectionProvider]) {
        if let builder = base.animatableBuilder {
            builder.sectionProviders.accept(sectionProviders)
        } else {
            self.base.animatableBuilder = AnimatableTableViewBuilder(tableView: self.base, sectionProviders: sectionProviders)
        }
    }
    
    public func build(_ providers: [_AnimatableTableViewMultiNodeProvider]) {
        if let builder = base.animatableBuilder {
            builder.sectionProviders.accept([AnimatableTableViewSectionProvider(providers: providers)])
        } else {
            self.base.animatableBuilder = AnimatableTableViewBuilder(tableView: self.base, providers: providers)
        }
    }
    
}

extension FlixProxy where Base: UICollectionView {
    
    public func build(_ sectionProviders: [CollectionViewSectionProvider]) {
        if let builder = base.builder {
            builder.sectionProviders.accept(sectionProviders)
        } else {
            self.base.builder = CollectionViewBuilder(collectionView: self.base, sectionProviders: sectionProviders)
        }
    }
    
    public func build(_ providers: [_CollectionViewMultiNodeProvider]) {
        if let builder = base.builder {
            builder.sectionProviders.accept([CollectionViewSectionProvider(providers: providers)])
        } else {
            self.base.builder = CollectionViewBuilder(collectionView: self.base, providers: providers)
        }
    }
    
}

extension FlixAnimatableProxy where Base: UICollectionView {
    
    public func build(_ sectionProviders: [AnimatableCollectionViewSectionProvider]) {
        if let builder = base.animatableBuilder {
            builder.sectionProviders.accept(sectionProviders)
        } else {
            self.base.animatableBuilder = AnimatableCollectionViewBuilder(collectionView: self.base, sectionProviders: sectionProviders)
        }
    }
    
    public func build(_ providers: [_AnimatableCollectionViewMultiNodeProvider]) {
        if let builder = base.animatableBuilder {
            builder.sectionProviders.accept([AnimatableCollectionViewSectionProvider(providers: providers)])
        } else {
            self.base.animatableBuilder = AnimatableCollectionViewBuilder(collectionView: self.base, providers: providers)
        }
    }
    
}
