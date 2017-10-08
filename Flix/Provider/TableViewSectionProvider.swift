//
//  TableViewSectionProvider.swift
//  Flix
//
//  Created by wc on 08/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

public class TableViewSectionProvider {
    
    public var headerProvider: _SectionPartionTableViewProvider?
    public var footerProvider: _SectionPartionTableViewProvider?
    public var providers: [_TableViewMultiNodeProvider]
    public let sectionProviderIdentity: String
    
    public init(
        identity: String,
        providers: [_TableViewMultiNodeProvider],
        headerProvider: _SectionPartionTableViewProvider? = nil,
        footerProvider: _SectionPartionTableViewProvider? = nil) {
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

public class AnimatableTableViewSectionProvider: TableViewSectionProvider {
    
    public var animatableHeaderProvider: _AnimatableSectionPartionTableViewProvider?
    public var animatableFooterProvider: _AnimatableSectionPartionTableViewProvider?
    public var animatableProviders: [_AnimatableTableViewMultiNodeProvider]
    
    public init(
        identity: String,
        providers: [_AnimatableTableViewMultiNodeProvider],
        headerProvider: _AnimatableSectionPartionTableViewProvider? = nil,
        footerProvider: _AnimatableSectionPartionTableViewProvider? = nil) {
        self.animatableProviders = providers
        self.animatableHeaderProvider = headerProvider
        self.animatableFooterProvider = footerProvider
        super.init(identity: identity, providers: providers, headerProvider: headerProvider, footerProvider: footerProvider)
    }
    
    func genteralAnimatableSectionModel() -> Observable<(section: IdentifiableSectionNode, nodes: [IdentifiableNode])> {
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
