//
//  CollectionViewSectionProvider.swift
//  Flix
//
//  Created by DianQK on 04/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

protocol _SectionNode {

    var identity: String { get }
    var headerNode: _Node? { get }
    var footerNode: _Node? { get }
    
}

struct IdentifiableSectionNode: IdentifiableType, _SectionNode {
    
    let identity: String
    let headerNode: _Node?
    let footerNode: _Node?
    
    init(identity: String, headerNode: IdentifiableNode? = nil, footerNode: IdentifiableNode? = nil) {
        self.identity = identity
        self.headerNode = headerNode
        self.footerNode = footerNode
    }
    
}

struct SectionNode: _SectionNode {
    
    let identity: String
    let headerNode: _Node?
    let footerNode: _Node?
    
    init(identity: String, headerNode: _Node? = nil, footerNode: _Node? = nil) {
        self.identity = identity
        self.headerNode = headerNode
        self.footerNode = footerNode
    }
    
}

public class CollectionViewSectionProvider: FlixCustomStringConvertible {
    
    public var headerProvider: _SectionPartionCollectionViewProvider?
    public var footerProvider: _SectionPartionCollectionViewProvider?
    public var providers: [_CollectionViewMultiNodeProvider]
    
    public init(providers: [_CollectionViewMultiNodeProvider], headerProvider: _SectionPartionCollectionViewProvider? = nil, footerProvider: _SectionPartionCollectionViewProvider? = nil) {
        self.providers = providers
        self.headerProvider = headerProvider
        self.footerProvider = footerProvider
    }
    
    func genteralSectionModel() -> Observable<(section: SectionNode, nodes: [Node])> {
        let headerSection = headerProvider?._genteralSectionPartion() ?? Observable.just(nil)
        let footerSection = footerProvider?._genteralSectionPartion() ?? Observable.just(nil)
        let nodes = Observable.combineLatest(providers.map { $0._genteralNodes() })
            .map { $0.flatMap { $0 } }
            .ifEmpty(default: [])
        
        let sectionProviderIdentity = self._flix_identity
        
        return Observable
            .combineLatest(headerSection, footerSection, nodes) { (headerSection, footerSection, nodes) -> (section: SectionNode, nodes: [Node]) in
                let section = SectionNode(identity: sectionProviderIdentity, headerNode: headerSection, footerNode: footerSection)
                return (section: section, nodes: nodes)
        }
    }
    
}


public class AnimatableCollectionViewSectionProvider: CollectionViewSectionProvider {
    
    public var animatableHeaderProvider: _AnimatableSectionPartionCollectionViewProvider?
    public var animatableFooterProvider: _AnimatableSectionPartionCollectionViewProvider?
    public var animatableProviders: [_AnimatableCollectionViewMultiNodeProvider]
    
    public init(providers: [_AnimatableCollectionViewMultiNodeProvider], headerProvider: _AnimatableSectionPartionCollectionViewProvider? = nil, footerProvider: _AnimatableSectionPartionCollectionViewProvider? = nil) {
        self.animatableHeaderProvider = headerProvider
        self.animatableFooterProvider = footerProvider
        self.animatableProviders = providers
        super.init(providers: providers, headerProvider: headerProvider, footerProvider: footerProvider)
    }
    
    func genteralSectionModel() -> Observable<(section: IdentifiableSectionNode, nodes: [IdentifiableNode])> {
        let headerSection = animatableHeaderProvider?._genteralAnimatableSectionPartion() ?? Observable.just(nil)
        let footerSection = animatableFooterProvider?._genteralAnimatableSectionPartion() ?? Observable.just(nil)

        let nodes = Observable.combineLatest(animatableProviders.map { $0._genteralAnimatableNodes() })
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
        
        let sectionProviderIdentity = self._flix_identity
        
        return Observable
            .combineLatest(headerSection, footerSection, nodes) { (headerSection, footerSection, nodes) -> (section: IdentifiableSectionNode, nodes: [IdentifiableNode]) in
                let section = IdentifiableSectionNode(identity: sectionProviderIdentity, headerNode: headerSection, footerNode: footerSection)
                return (section: section, nodes: nodes)
        }
    }
    
}
