//
//  AnimatableCollectionViewBuilder.swift
//  Flix
//
//  Created by DianQK on 03/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

public class AnimatableCollectionViewBuilder {
    
    typealias AnimatableSectionModel = RxDataSources.AnimatableSectionModel<IdentifiableSectionNode, IdentifiableNode>
    
    let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel>()
    let disposeBag = DisposeBag()
    let delegeteService = CollectionViewDelegateService()
    
    public var animationConfiguration: AnimationConfiguration {
        get {
            return dataSource.animationConfiguration
        }
        set {
            dataSource.animationConfiguration = newValue
        }
    }
    
    public init(collectionView: UICollectionView, sectionProviders: [CollectionViewSectionProvider]) {

        self.animationConfiguration = AnimationConfiguration(
            insertAnimation: .fade,
            reloadAnimation: .none,
            deleteAnimation: .fade
        )

        let nodeProviders: [_AnimatableCollectionViewMultiNodeProvider] = sectionProviders.flatMap { $0.providers }
        let footerSectionProviders: [_AnimatableSectionPartionCollectionViewProvider] = sectionProviders.flatMap { $0.footerProvider }
        let headerSectionProviders: [_AnimatableSectionPartionCollectionViewProvider] = sectionProviders.flatMap { $0.headerProvider }
        
        dataSource.configureCell = { dataSource, collectionView, indexPath, node in
            let provider = nodeProviders.first(where: { $0.identity == node.node.providerIdentity })!
            return provider._configureCell(collectionView, indexPath: indexPath, node: node.node)
        }

        dataSource.supplementaryViewFactory = { dataSource, collectionView, kind, indexPath in
            switch UICollectionElementKindSection(rawValue: kind)! {
            case .footer:
                guard let node = dataSource[indexPath.section].model.footerNode else { fatalError() }
                let provider = footerSectionProviders.first(where: { $0.identity == node.node.providerIdentity })!
                let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: provider.identity, for: indexPath)
                provider._configureSupplementaryView(collectionView, sectionView: reusableView, indexPath: indexPath, node: node.node)
                return reusableView
            case .header:
                guard let node = dataSource[indexPath.section].model.headerNode else { fatalError() }
                let provider = headerSectionProviders.first(where: { $0.identity == node.node.providerIdentity })!
                let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: provider.identity, for: indexPath)
                provider._configureSupplementaryView(collectionView, sectionView: reusableView, indexPath: indexPath, node: node.node)
                return reusableView
            }
        }
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak collectionView, unowned self] (indexPath) in
                guard let `collectionView` = collectionView else { return }
                let node = self.dataSource[indexPath].node
                let provider = nodeProviders.first(where: { $0.identity == node.providerIdentity })!
                provider._tap(collectionView, indexPath: indexPath, node: node)
            })
            .disposed(by: disposeBag)
        
        for provider in nodeProviders {
            provider.register(collectionView)
        }
        
        for provider in footerSectionProviders {
            provider.register(collectionView)
        }
        
        for provider in headerSectionProviders {
            provider.register(collectionView)
        }
        
        Observable.combineLatest(sectionProviders.map { $0.genteralSectionModel() })
            .map { $0.map { AnimatableSectionModel(model: $0.section, items: $0.nodes) } }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        self.delegeteService.sizeForItem = { [weak self] collectionView, flowLayout, indexPath in
            guard let node = self?.dataSource[indexPath].node else { return nil }
            let providerIdentity = node.providerIdentity
            let provider = nodeProviders.first(where: { $0.identity == providerIdentity })!
            return provider._collectionView(collectionView, layout: flowLayout, sizeForItemAt: indexPath, node: node)
        }
        
        self.delegeteService.referenceSizeForFooterInSection = { [weak self] collectionView, collectionViewLayout, section in
            guard let footerNode = self?.dataSource[section].model.footerNode?.node else { return CGSize.zero }
            let providerIdentity = footerNode.providerIdentity
            let provider = footerSectionProviders.first(where: { $0.identity == providerIdentity })!
            return provider._collectionView(collectionView, layout: collectionViewLayout, referenceSizeInSection: section, node: footerNode)
        }
        
        self.delegeteService.referenceSizeForHeaderInSection = { [weak self] collectionView, collectionViewLayout, section in
            guard let footerNode = self?.dataSource[section].model.headerNode?.node else { return CGSize.zero }
            let providerIdentity = footerNode.providerIdentity
            let provider = headerSectionProviders.first(where: { $0.identity == providerIdentity })!
            return provider._collectionView(collectionView, layout: collectionViewLayout, referenceSizeInSection: section, node: footerNode)
        }
        
        collectionView.rx.setDelegate(self.delegeteService).disposed(by: disposeBag)
    }
    
    public convenience init(collectionView: UICollectionView, providers: [_AnimatableCollectionViewMultiNodeProvider]) {
        let sectionProviderCollectionViewBuilder = CollectionViewSectionProvider(
            identity: "Flix",
            providers: providers,
            headerProvider: nil,
            footerProvider: nil
        )
        self.init(collectionView: collectionView, sectionProviders: [sectionProviderCollectionViewBuilder])
    }
    
}

class CollectionViewDelegateService: NSObject, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewLayout = collectionViewLayout as! UICollectionViewFlowLayout
        return sizeForItem?(collectionView, collectionViewLayout, indexPath) ?? collectionViewLayout.itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let collectionViewLayout = collectionViewLayout as! UICollectionViewFlowLayout
        return referenceSizeForFooterInSection?(collectionView, collectionViewLayout, section) ?? collectionViewLayout.footerReferenceSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let collectionViewLayout = collectionViewLayout as! UICollectionViewFlowLayout
        return referenceSizeForHeaderInSection?(collectionView, collectionViewLayout, section) ?? collectionViewLayout.headerReferenceSize
    }
    
    var sizeForItem: ((_ collectionView: UICollectionView, _ collectionViewLayout: UICollectionViewLayout, _ indexPath: IndexPath) -> CGSize?)?
    var referenceSizeForFooterInSection: ((_ collectionView: UICollectionView, _ collectionViewLayout: UICollectionViewLayout, _ section: Int) -> CGSize?)?
    var referenceSizeForHeaderInSection: ((_ collectionView: UICollectionView, _ collectionViewLayout: UICollectionViewLayout, _ section: Int) -> CGSize?)?
    
}
