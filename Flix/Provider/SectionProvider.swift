//
//  SectionProvider.swift
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
    
    var identity: String
    let headerNode: IdentifiableNode?
    let footerNode: IdentifiableNode?
    
    init(identity: String, headerNode: IdentifiableNode? = nil, footerNode: IdentifiableNode? = nil) {
        self.identity = identity
        self.headerNode = headerNode
        self.footerNode = footerNode
    }
    
}

public class CollectionViewSectionProvider {
    
    let headerProvider: _AnimatableSectionPartionCollectionViewProvider?
    let footerProvider: _AnimatableSectionPartionCollectionViewProvider?
    let providers: [_AnimatableCollectionViewMultiNodeProvider]
    public let sectionProviderIdentity: String
    
    public init(identity: String, providers: [_AnimatableCollectionViewMultiNodeProvider], headerProvider: _AnimatableSectionPartionCollectionViewProvider? = nil, footerProvider: _AnimatableSectionPartionCollectionViewProvider? = nil) {
        self.sectionProviderIdentity = identity
        self.providers = providers
        self.headerProvider = headerProvider
        self.footerProvider = footerProvider
    }
    
    func genteralSectionModel() -> Observable<(section: IdentifiableSectionNode, nodes: [IdentifiableNode])> {
        let headerSection = headerProvider?._genteralAnimatableSectionPartion() ?? Observable.just(nil)
        let footerSection = footerProvider?._genteralAnimatableSectionPartion() ?? Observable.just(nil)
        let nodes = Observable.combineLatest(providers.map { $0._genteralAnimatableNodes() })
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


public class TableViewSectionProvider {
    
    var headerProvider: _AnimatableSectionPartionTableViewProvider?
    var footerProvider: _AnimatableSectionPartionTableViewProvider?
    var providers: [_AnimatableTableViewMultiNodeProvider] = []
    public var sectionProviderIdentity = ""
    
    public init(
        identity: String,
        providers: [_AnimatableTableViewMultiNodeProvider],
        headerProvider: _AnimatableSectionPartionTableViewProvider? = nil,
        footerProvider: _AnimatableSectionPartionTableViewProvider? = nil) {
        self.sectionProviderIdentity = identity
        self.providers = providers
        self.headerProvider = headerProvider
        self.footerProvider = footerProvider
    }
    
    func genteralSectionModel() -> Observable<(section: IdentifiableSectionNode, nodes: [IdentifiableNode])> {
        let headerSection = headerProvider?._genteralAnimatableSectionPartion() ?? Observable.just(nil)
        let footerSection = footerProvider?._genteralAnimatableSectionPartion() ?? Observable.just(nil)
        let nodes = Observable.combineLatest(providers.map { $0._genteralAnimatableNodes() })
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
