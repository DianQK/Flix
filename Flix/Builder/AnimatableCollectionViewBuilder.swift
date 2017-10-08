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
    
    public let sectionProviders: Variable<[AnimatableCollectionViewSectionProvider]>

    private var nodeProviders: [_AnimatableCollectionViewMultiNodeProvider] = [] {
        didSet {
            for provider in nodeProviders {
                provider.register(collectionView)
            }
        }
    }
    private var footerSectionProviders: [_AnimatableSectionPartionCollectionViewProvider] = [] {
        didSet {
            for provider in footerSectionProviders {
                provider.register(collectionView)
            }
        }
    }
    private var headerSectionProviders: [_AnimatableSectionPartionCollectionViewProvider] = [] {
        didSet {
            for provider in headerSectionProviders {
                provider.register(collectionView)
            }
        }
    }
    
    let collectionView: UICollectionView
    
    public init(collectionView: UICollectionView, sectionProviders: [AnimatableCollectionViewSectionProvider]) {
        
        self.collectionView = collectionView
        
        self.sectionProviders = Variable(sectionProviders)

        self.animationConfiguration = AnimationConfiguration(
            insertAnimation: .fade,
            reloadAnimation: .none,
            deleteAnimation: .fade
        )
        
        dataSource.configureCell = { [weak self] dataSource, collectionView, indexPath, node in
            guard let provider = self?.nodeProviders.first(where: { $0.identity == node.node.providerIdentity }) else { return UICollectionViewCell() }
            return provider._configureCell(collectionView, indexPath: indexPath, node: node.node)
        }

        dataSource.supplementaryViewFactory = { [weak self] dataSource, collectionView, kind, indexPath in
            switch UICollectionElementKindSection(rawValue: kind)! {
            case .footer:
                guard let node = dataSource[indexPath.section].model.footerNode else { fatalError() }
                guard let provider = self?.footerSectionProviders.first(where: { $0.identity == node.node.providerIdentity }) else { return UICollectionReusableView() }
                let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: provider.identity, for: indexPath)
                provider._configureSupplementaryView(collectionView, sectionView: reusableView, indexPath: indexPath, node: node.node)
                return reusableView
            case .header:
                guard let node = dataSource[indexPath.section].model.headerNode else { fatalError() }
                guard let provider = self?.headerSectionProviders.first(where: { $0.identity == node.node.providerIdentity }) else { return UICollectionReusableView() }
                let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: provider.identity, for: indexPath)
                provider._configureSupplementaryView(collectionView, sectionView: reusableView, indexPath: indexPath, node: node.node)
                return reusableView
            }
        }
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak collectionView, unowned self] (indexPath) in
                guard let `collectionView` = collectionView else { return }
                let node = self.dataSource[indexPath].node
                let provider = self.nodeProviders.first(where: { $0.identity == node.providerIdentity })!
                provider._tap(collectionView, indexPath: indexPath, node: node)
            })
            .disposed(by: disposeBag)
        
        self.delegeteService.sizeForItem = { [unowned self] collectionView, flowLayout, indexPath in
            let node = self.dataSource[indexPath].node
            let providerIdentity = node.providerIdentity
            let provider = self.nodeProviders.first(where: { $0.identity == providerIdentity })!
            return provider._collectionView(collectionView, layout: flowLayout, sizeForItemAt: indexPath, node: node)
        }
        
        self.delegeteService.referenceSizeForFooterInSection = { [unowned self] collectionView, collectionViewLayout, section in
            guard let footerNode = self.dataSource[section].model.footerNode?.node else { return CGSize.zero }
            let providerIdentity = footerNode.providerIdentity
            let provider = self.footerSectionProviders.first(where: { $0.identity == providerIdentity })!
            return provider._collectionView(collectionView, layout: collectionViewLayout, referenceSizeInSection: section, node: footerNode)
        }
        
        self.delegeteService.referenceSizeForHeaderInSection = { [unowned self] collectionView, collectionViewLayout, section in
            guard let footerNode = self.dataSource[section].model.headerNode?.node else { return CGSize.zero }
            let providerIdentity = footerNode.providerIdentity
            let provider = self.headerSectionProviders.first(where: { $0.identity == providerIdentity })!
            return provider._collectionView(collectionView, layout: collectionViewLayout, referenceSizeInSection: section, node: footerNode)
        }
        
        collectionView.rx.setDelegate(self.delegeteService).disposed(by: disposeBag)
        
        self.sectionProviders.asObservable()
            .do(onNext: { [weak self] (sectionProviders) in
                self?.nodeProviders = sectionProviders.flatMap { $0.animatableProviders }
                self?.footerSectionProviders = sectionProviders.flatMap { $0.animatableFooterProvider }
                self?.headerSectionProviders = sectionProviders.flatMap { $0.animatableHeaderProvider }
            })
            .flatMapLatest { (providers) -> Observable<[AnimatableSectionModel]> in
                let sections: [Observable<(section: IdentifiableSectionNode, nodes: [IdentifiableNode])>] = providers.map { $0.genteralSectionModel() }
                return Observable.combineLatest(sections).map { $0.map { AnimatableSectionModel(model: $0.section, items: $0.nodes) } }
            }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    public convenience init(collectionView: UICollectionView, providers: [_AnimatableCollectionViewMultiNodeProvider]) {
        let sectionProviderCollectionViewBuilder = AnimatableCollectionViewSectionProvider(
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
