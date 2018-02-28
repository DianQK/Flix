//
//  CollectionViewBuilder.swift
//  Flix
//
//  Created by DianQK on 08/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

public class CollectionViewBuilder: _CollectionViewBuilder {
    
    typealias SectionModel = RxDataSources.SectionModel<SectionNode, Node>

    let disposeBag = DisposeBag()
    let delegeteProxy = CollectionViewDelegateProxy()
    
    public let sectionProviders: BehaviorRelay<[CollectionViewSectionProvider]>
    
    var nodeProviders: [_CollectionViewMultiNodeProvider] = [] {
        didSet {
            for provider in nodeProviders {
                provider.register(collectionView)
            }
        }
    }
    var footerSectionProviders: [_SectionPartionCollectionViewProvider] = [] {
        didSet {
            for provider in footerSectionProviders {
                provider.register(collectionView)
            }
        }
    }
    var headerSectionProviders: [_SectionPartionCollectionViewProvider] = [] {
        didSet {
            for provider in headerSectionProviders {
                provider.register(collectionView)
            }
        }
    }
    
    weak var _collectionView: UICollectionView?

    var collectionView: UICollectionView {
        return self._collectionView!
    }

    public init(collectionView: UICollectionView, sectionProviders: [CollectionViewSectionProvider]) {
        
        self._collectionView = collectionView
        
        self.sectionProviders = BehaviorRelay(value: sectionProviders)
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel>(configureCell: { [weak self] dataSource, collectionView, indexPath, node in
            guard let provider = self?.nodeProviders.first(where: { $0._flix_identity == node.providerIdentity }) else { return UICollectionViewCell() }
            return provider._configureCell(collectionView, indexPath: indexPath, node: node)
            }, configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath in
                switch UICollectionElementKindSection(rawValue: kind)! {
                case .footer:
                    guard let node = dataSource[indexPath.section].model.footerNode else { fatalError() }
                    guard let provider = self?.footerSectionProviders.first(where: { $0._flix_identity == node.providerIdentity }) else { return UICollectionReusableView() }
                    let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: provider._flix_identity, for: indexPath)
                    provider._configureSupplementaryView(collectionView, sectionView: reusableView, indexPath: indexPath, node: node)
                    return reusableView
                case .header:
                    guard let node = dataSource[indexPath.section].model.headerNode else { fatalError() }
                    guard let provider = self?.headerSectionProviders.first(where: { $0._flix_identity == node.providerIdentity }) else { return UICollectionReusableView() }
                    let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: provider._flix_identity, for: indexPath)
                    provider._configureSupplementaryView(collectionView, sectionView: reusableView, indexPath: indexPath, node: node)
                    return reusableView
                }
        })

        self.build(dataSource: dataSource)
        
        self.sectionProviders.asObservable()
            .do(onNext: { [weak self] (sectionProviders) in
                self?.nodeProviders = sectionProviders.flatMap { $0.providers.flatMap { $0.__providers } }
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
        let sectionProviderCollectionViewBuilder = CollectionViewSectionProvider(providers: providers)
        self.init(collectionView: collectionView, sectionProviders: [sectionProviderCollectionViewBuilder])
    }
    
}
