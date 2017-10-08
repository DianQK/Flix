//
//  CollectionViewBuilder.swift
//  Flix
//
//  Created by wc on 08/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

public class CollectionViewBuilder {
    
    typealias SectionModel = RxDataSources.SectionModel<SectionNode, _Node>
    
    let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel>()
    let disposeBag = DisposeBag()
    let delegeteService = CollectionViewDelegateService()
    
    public let sectionProviders: Variable<[CollectionViewSectionProvider]>
    
    private var nodeProviders: [_CollectionViewMultiNodeProvider] = [] {
        didSet {
            for provider in nodeProviders {
                provider.register(collectionView)
            }
        }
    }
    private var footerSectionProviders: [_SectionPartionCollectionViewProvider] = [] {
        didSet {
            for provider in footerSectionProviders {
                provider.register(collectionView)
            }
        }
    }
    private var headerSectionProviders: [_SectionPartionCollectionViewProvider] = [] {
        didSet {
            for provider in headerSectionProviders {
                provider.register(collectionView)
            }
        }
    }
    
    let collectionView: UICollectionView

    public init(collectionView: UICollectionView, sectionProviders: [CollectionViewSectionProvider]) {
        
        self.collectionView = collectionView
        
        self.sectionProviders = Variable(sectionProviders)
        
        dataSource.configureCell = { [weak self] dataSource, collectionView, indexPath, node in
            guard let provider = self?.nodeProviders.first(where: { $0.identity == node.providerIdentity }) else { return UICollectionViewCell() }
            return provider._configureCell(collectionView, indexPath: indexPath, node: node)
        }
        
        dataSource.supplementaryViewFactory = { [weak self] dataSource, collectionView, kind, indexPath in
            switch UICollectionElementKindSection(rawValue: kind)! {
            case .footer:
                guard let node = dataSource[indexPath.section].model.footerNode else { fatalError() }
                guard let provider = self?.footerSectionProviders.first(where: { $0.identity == node.providerIdentity }) else { return UICollectionReusableView() }
                let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: provider.identity, for: indexPath)
                provider._configureSupplementaryView(collectionView, sectionView: reusableView, indexPath: indexPath, node: node)
                return reusableView
            case .header:
                guard let node = dataSource[indexPath.section].model.headerNode else { fatalError() }
                guard let provider = self?.headerSectionProviders.first(where: { $0.identity == node.providerIdentity }) else { return UICollectionReusableView() }
                let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: provider.identity, for: indexPath)
                provider._configureSupplementaryView(collectionView, sectionView: reusableView, indexPath: indexPath, node: node)
                return reusableView
            }
        }
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak collectionView, unowned self] (indexPath) in
                guard let `collectionView` = collectionView else { return }
                let node = self.dataSource[indexPath]
                let provider = self.nodeProviders.first(where: { $0.identity == node.providerIdentity })!
                provider._tap(collectionView, indexPath: indexPath, node: node)
            })
            .disposed(by: disposeBag)
        
        self.delegeteService.sizeForItem = { [unowned self] collectionView, flowLayout, indexPath in
            let node = self.dataSource[indexPath]
            let providerIdentity = node.providerIdentity
            let provider = self.nodeProviders.first(where: { $0.identity == providerIdentity })!
            return provider._collectionView(collectionView, layout: flowLayout, sizeForItemAt: indexPath, node: node)
        }
        
        self.delegeteService.referenceSizeForFooterInSection = { [unowned self] collectionView, collectionViewLayout, section in
            guard let footerNode = self.dataSource[section].model.footerNode else { return CGSize.zero }
            let providerIdentity = footerNode.providerIdentity
            let provider = self.footerSectionProviders.first(where: { $0.identity == providerIdentity })!
            return provider._collectionView(collectionView, layout: collectionViewLayout, referenceSizeInSection: section, node: footerNode)
        }
        
        self.delegeteService.referenceSizeForHeaderInSection = { [unowned self] collectionView, collectionViewLayout, section in
            guard let footerNode = self.dataSource[section].model.headerNode else { return CGSize.zero }
            let providerIdentity = footerNode.providerIdentity
            let provider = self.headerSectionProviders.first(where: { $0.identity == providerIdentity })!
            return provider._collectionView(collectionView, layout: collectionViewLayout, referenceSizeInSection: section, node: footerNode)
        }
        
        collectionView.rx.setDelegate(self.delegeteService).disposed(by: disposeBag)
        
        self.sectionProviders.asObservable()
            .do(onNext: { [weak self] (sectionProviders) in
                self?.nodeProviders = sectionProviders.flatMap { $0.providers }
                self?.footerSectionProviders = sectionProviders.flatMap { $0.footerProvider }
                self?.headerSectionProviders = sectionProviders.flatMap { $0.headerProvider }
            })
            .flatMapLatest { (providers) -> Observable<[SectionModel]> in
                let sections = providers.map { $0.genteralSectionModel() }
                return Observable.combineLatest(sections).map { $0.map { SectionModel(model: $0.section, items: $0.nodes) } }
            }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    public convenience init(collectionView: UICollectionView, providers: [_CollectionViewMultiNodeProvider]) {
        let sectionProviderCollectionViewBuilder = CollectionViewSectionProvider(
            identity: "Flix",
            providers: providers,
            headerProvider: nil,
            footerProvider: nil
        )
        self.init(collectionView: collectionView, sectionProviders: [sectionProviderCollectionViewBuilder])
    }
    
}
