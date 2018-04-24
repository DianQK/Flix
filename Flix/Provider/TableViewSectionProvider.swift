//
//  TableViewSectionProvider.swift
//  Flix
//
//  Created by DianQK on 08/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

open class TableViewSectionProvider: FlixCustomStringConvertible, ProviderHiddenable {
    
    public let headerProvider: _SectionPartionTableViewProvider?
    public let footerProvider: _SectionPartionTableViewProvider?
    public let providers: [_TableViewMultiNodeProvider]

    public var isHidden: Bool {
        get {
            return _isHidden.value
        }
        set {
            _isHidden.accept(newValue)
        }
    }

    fileprivate let _isHidden = BehaviorRelay(value: false)
    
    public init(
        providers: [_TableViewMultiNodeProvider],
        headerProvider: _SectionPartionTableViewProvider? = nil,
        footerProvider: _SectionPartionTableViewProvider? = nil) {
        self.providers = providers
        self.headerProvider = headerProvider
        self.footerProvider = footerProvider
    }
    
    func createSectionModel() -> Observable<(section: SectionNode, nodes: [Node])?> {
        let headerSection = headerProvider?._createSectionPartion() ?? Observable.just(nil)
        let footerSection = footerProvider?._createSectionPartion() ?? Observable.just(nil)
        let nodes = Observable.combineLatest(providers.map { $0._createNodes() })
            .ifEmpty(default: [])
            .map { (value) -> [Node] in
                return value.reduce([Node]()) { acc, x in
                    let nodeCount = x.count
                    let accCount = acc.count
                    let nodes = x.map { node -> Node in
                        var node = node
                        node.providerStartIndexPath.row = accCount
                        node.providerEndIndexPath.row = accCount + nodeCount - 1
                        return node
                    }
                    return acc + nodes
                }
        }
        
        let sectionProviderIdentity = self._flix_identity
        
        let isHidden = self._isHidden.asObservable().distinctUntilChanged()
        
        return Observable
            .combineLatest(headerSection, footerSection, nodes, isHidden) { (headerSection, footerSection, nodes, isHidden) -> (section: SectionNode, nodes: [Node])? in
                if isHidden {
                    return nil
                } else {
                    let section = SectionNode(identity: sectionProviderIdentity, headerNode: headerSection, footerNode: footerSection)
                    return (section: section, nodes: nodes)
                }
        }
    }

}

open class AnimatableTableViewSectionProvider: TableViewSectionProvider {
    
    public var animatableHeaderProvider: _AnimatableSectionPartionTableViewProvider?
    public var animatableFooterProvider: _AnimatableSectionPartionTableViewProvider?
    public var animatableProviders: [_AnimatableTableViewMultiNodeProvider]
    
    public init(
        providers: [_AnimatableTableViewMultiNodeProvider],
        headerProvider: _AnimatableSectionPartionTableViewProvider? = nil,
        footerProvider: _AnimatableSectionPartionTableViewProvider? = nil) {
        self.animatableProviders = providers
        self.animatableHeaderProvider = headerProvider
        self.animatableFooterProvider = footerProvider
        super.init(providers: providers, headerProvider: headerProvider, footerProvider: footerProvider)
    }
    
    func createSectionModel() -> Observable<(section: IdentifiableSectionNode, nodes: [IdentifiableNode])?> {
        let headerSection = animatableHeaderProvider?._createAnimatableSectionPartion() ?? Observable.just(nil)
        let footerSection = animatableFooterProvider?._createAnimatableSectionPartion() ?? Observable.just(nil)
        let nodes = Observable.combineLatest(animatableProviders.map { $0._createAnimatableNodes() })
            .ifEmpty(default: [])
            .map { (value) -> [IdentifiableNode] in
                return value.reduce([IdentifiableNode]()) { acc, x in
                    let nodeCount = x.count
                    let accCount = acc.count
                    let nodes = x.map { node -> IdentifiableNode in
                        var node = node
                        node.providerStartIndexPath.row = accCount
                        node.providerEndIndexPath.row = accCount + nodeCount - 1
                        return node
                    }
                    return acc + nodes
                }
            }

        let isHidden = self._isHidden.asObservable().distinctUntilChanged()
        
        let sectionProviderIdentity = self._flix_identity
        
        return Observable
            .combineLatest(headerSection, footerSection, nodes, isHidden) { (headerSection, footerSection, nodes, isHidden) -> (section: IdentifiableSectionNode, nodes: [IdentifiableNode])? in
                if isHidden || (headerSection == nil && footerSection == nil && nodes.isEmpty) {
                    return nil
                } else {
                    let section = IdentifiableSectionNode(identity: sectionProviderIdentity, headerNode: headerSection, footerNode: footerSection)
                    return (section: section, nodes: nodes)
                }
        }
    }
    
}
