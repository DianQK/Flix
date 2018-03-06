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

public class AnimatableCollectionViewBuilder: _CollectionViewBuilder {
    
    typealias AnimatableSectionModel = RxDataSources.AnimatableSectionModel<IdentifiableSectionNode, IdentifiableNode>

    let disposeBag = DisposeBag()
    let delegeteProxy = CollectionViewDelegateProxy()
    
    public let sectionProviders: BehaviorRelay<[AnimatableCollectionViewSectionProvider]>

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

    public var decideViewTransition: (([ChangesetInfo]) -> ViewTransition)?

    weak var _collectionView: UICollectionView?

    var collectionView: UICollectionView {
        return self._collectionView!
    }
    
    public init(collectionView: UICollectionView, sectionProviders: [AnimatableCollectionViewSectionProvider]) {
        
        self._collectionView = collectionView
        
        self.sectionProviders = BehaviorRelay(value: sectionProviders)
        
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel>(
            configureCell: { [weak self] dataSource, collectionView, indexPath, node in
                guard let provider = self?.nodeProviders.first(where: { $0._flix_identity == node.providerIdentity }) else { return UICollectionViewCell() }
                return provider._configureCell(collectionView, indexPath: indexPath, node: node)
            },
            configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath in
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

        dataSource.decideViewTransition = { [weak self] (_, _, changesets) -> ViewTransition in
            return self?.decideViewTransition?(changesets) ?? ViewTransition.animated
        }
        
        dataSource.animationConfiguration = AnimationConfiguration(
            insertAnimation: .fade,
            reloadAnimation: .none,
            deleteAnimation: .fade
        )
        
        self.build(dataSource: dataSource)
        
        self.sectionProviders.asObservable()
            .do(onNext: { [weak self] (sectionProviders) in
                self?.nodeProviders = sectionProviders.flatMap { $0.animatableProviders.flatMap { $0.__providers } }
                self?.footerSectionProviders = sectionProviders.flatMap { $0.animatableFooterProvider }
                self?.headerSectionProviders = sectionProviders.flatMap { $0.animatableHeaderProvider }
            })
            .flatMapLatest { (providers) -> Observable<[AnimatableSectionModel]> in
                let sections: [Observable<(section: IdentifiableSectionNode, nodes: [IdentifiableNode])>] = providers.map { $0.genteralSectionModel() }
                return Observable.combineLatest(sections)
                    .ifEmpty(default: [])
                    .map { value -> [AnimatableSectionModel] in
                        return value.enumerated()
                            .map { (offset, section) -> AnimatableSectionModel in
                                let items = section.nodes.map { (node) -> IdentifiableNode in
                                    var node = node
                                    node.providerStartIndexPath.section = offset
                                    node.providerEndIndexPath.section = offset
                                    return node
                                }
                                return AnimatableSectionModel(model: section.section, items: items)
                        }
                }
            }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    public convenience init(collectionView: UICollectionView, providers: [_AnimatableCollectionViewMultiNodeProvider]) {
        let sectionProviderCollectionViewBuilder = AnimatableCollectionViewSectionProvider(providers: providers)
        self.init(collectionView: collectionView, sectionProviders: [sectionProviderCollectionViewBuilder])
    }
    
}
