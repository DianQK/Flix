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

struct IdentifiableSectionNode: IdentifiableType {
    
    let identity: String
    let headerNode: IdentifiableNode?
    let footerNode: IdentifiableNode?
    
    init(identity: String, headerNode: IdentifiableNode? = nil, footerNode: IdentifiableNode? = nil) {
        self.identity = identity
        self.headerNode = headerNode
        self.footerNode = footerNode
    }
    
}

struct SectionNode {
    
    let identity: String
    let headerNode: _Node?
    let footerNode: _Node?
    
    init(identity: String, headerNode: _Node? = nil, footerNode: _Node? = nil) {
        self.identity = identity
        self.headerNode = headerNode
        self.footerNode = footerNode
    }
    
}

public class CollectionViewSectionProvider {
    
    let headerProvider: _SectionPartionCollectionViewProvider?
    let footerProvider: _SectionPartionCollectionViewProvider?
    let providers: [_CollectionViewMultiNodeProvider]
    public let sectionProviderIdentity: String
    
    public init(identity: String, providers: [_CollectionViewMultiNodeProvider], headerProvider: _SectionPartionCollectionViewProvider? = nil, footerProvider: _SectionPartionCollectionViewProvider? = nil) {
        self.sectionProviderIdentity = identity
        self.providers = providers
        self.headerProvider = headerProvider
        self.footerProvider = footerProvider
    }
    
    func genteralSectionModel() -> Observable<(section: SectionNode, nodes: [_Node])> {
        let headerSection = headerProvider?._genteralSectionPartion() ?? Observable.just(nil)
        let footerSection = footerProvider?._genteralSectionPartion() ?? Observable.just(nil)
        let nodes = Observable.combineLatest(providers.map { $0._genteralNodes() })
            .map { $0.flatMap { $0 } }
            .ifEmpty(default: [])
        
        let sectionProviderIdentity = self.sectionProviderIdentity
        
        return Observable
            .combineLatest(headerSection, footerSection, nodes) { (headerSection, footerSection, nodes) -> (section: SectionNode, nodes: [_Node]) in
                let section = SectionNode(identity: sectionProviderIdentity, headerNode: headerSection, footerNode: footerSection)
                return (section: section, nodes: nodes)
        }
    }
    
}


public class AnimatableCollectionViewSectionProvider: CollectionViewSectionProvider {
    
    let animatableHeaderProvider: _AnimatableSectionPartionCollectionViewProvider?
    let animatableFooterProvider: _AnimatableSectionPartionCollectionViewProvider?
    let animatableProviders: [_AnimatableCollectionViewMultiNodeProvider]
    
    public init(identity: String, providers: [_AnimatableCollectionViewMultiNodeProvider], headerProvider: _AnimatableSectionPartionCollectionViewProvider? = nil, footerProvider: _AnimatableSectionPartionCollectionViewProvider? = nil) {
        self.animatableHeaderProvider = headerProvider
        self.animatableFooterProvider = footerProvider
        self.animatableProviders = providers
        super.init(identity: identity, providers: providers, headerProvider: headerProvider, footerProvider: footerProvider)
    }
    
    func genteralSectionModel() -> Observable<(section: IdentifiableSectionNode, nodes: [IdentifiableNode])> {
        let headerSection = animatableHeaderProvider?._genteralAnimatableSectionPartion() ?? Observable.just(nil)
        let footerSection = animatableFooterProvider?._genteralAnimatableSectionPartion() ?? Observable.just(nil)
        let nodes = Observable.combineLatest(animatableProviders.map { $0._genteralAnimatableNodes() })
            .map { $0.flatMap { $0 } }
            .ifEmpty(default: [])
        
        let sectionProviderIdentity = self.sectionProviderIdentity
        
        return Observable
            .combineLatest(headerSection, footerSection, nodes) { (headerSection, footerSection, nodes) -> (section: IdentifiableSectionNode, nodes: [IdentifiableNode]) in
                let section = IdentifiableSectionNode(identity: sectionProviderIdentity, headerNode: headerSection, footerNode: footerSection)
                return (section: section, nodes: nodes)
        }
    }
    
}
