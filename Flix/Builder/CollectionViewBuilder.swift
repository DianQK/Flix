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

public class CollectionViewBuilder: _CollectionViewBuilder, PerformGroupUpdatesable {
    
    typealias SectionModel = RxDataSources.SectionModel<SectionNode, Node>

    let disposeBag = DisposeBag()
    let delegeteProxy = CollectionViewDelegateProxy()
    
    public let sectionProviders: BehaviorRelay<[CollectionViewSectionProvider]>
    
    var nodeProviders: [String: _CollectionViewMultiNodeProvider] = [:] {
        didSet {
            nodeProviders.forEach { (_, provider) in
                provider._register(collectionView)
            }
        }
    }
    var footerSectionProviders: [String: _SectionPartionCollectionViewProvider] = [:] {
        didSet {
            footerSectionProviders.forEach { (_, provider) in
                provider.register(collectionView)
            }
        }
    }
    var headerSectionProviders: [String: _SectionPartionCollectionViewProvider] = [:] {
        didSet {
            headerSectionProviders.forEach { (_, provider) in
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
            guard let provider = self?.nodeProviders[node.providerIdentity] else { return UICollectionViewCell() }
            return provider._configureCell(collectionView, indexPath: indexPath, node: node)
            }, configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath in
                switch UICollectionElementKindSection(rawValue: kind)! {
                case .footer:
                    guard let node = dataSource[indexPath.section].model.footerNode else { fatalError() }
                    guard let provider = self?.footerSectionProviders[node.providerIdentity] else { return UICollectionReusableView() }
                    let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: provider._flix_identity, for: indexPath)
                    provider._configureSupplementaryView(collectionView, sectionView: reusableView, indexPath: indexPath, node: node)
                    return reusableView
                case .header:
                    guard let node = dataSource[indexPath.section].model.headerNode else { fatalError() }
                    guard let provider = self?.headerSectionProviders[node.providerIdentity] else { return UICollectionReusableView() }
                    let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: provider._flix_identity, for: indexPath)
                    provider._configureSupplementaryView(collectionView, sectionView: reusableView, indexPath: indexPath, node: node)
                    return reusableView
                }
        })

        self.build(dataSource: dataSource)
        
        self.sectionProviders.asObservable()
            .do(onNext: { [weak self] (sectionProviders) in
                self?.nodeProviders = Dictionary(
                    uniqueKeysWithValues: sectionProviders
                        .flatMap { $0.providers.flatMap { $0.__providers.map { (key: $0._flix_identity, value: $0) } }
                })
                self?.footerSectionProviders = Dictionary(
                    uniqueKeysWithValues: sectionProviders.compactMap { $0.footerProvider.map { (key: $0._flix_identity, value: $0) } })
                self?.headerSectionProviders = Dictionary(
                    uniqueKeysWithValues: sectionProviders.compactMap { $0.headerProvider.map { (key: $0._flix_identity, value: $0) } })
            })
            .flatMapLatest { (providers) -> Observable<[SectionModel]> in
                let sections = providers.compactMap { $0.createSectionModel() }
                return Observable.combineLatest(sections)
                    .ifEmpty(default: [])
                    .map { value -> [SectionModel] in
                        return BuilderTool.combineSections(value)
                }
            }
            .sendLatest(when: performGroupUpdatesBehaviorRelay)
            .debounce(0, scheduler: MainScheduler.instance)
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    public convenience init(collectionView: UICollectionView, providers: [_CollectionViewMultiNodeProvider]) {
        let sectionProviderCollectionViewBuilder = CollectionViewSectionProvider(providers: providers)
        self.init(collectionView: collectionView, sectionProviders: [sectionProviderCollectionViewBuilder])
    }
    
}
