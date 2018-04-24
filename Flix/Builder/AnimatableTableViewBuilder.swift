//
//  AnimatableTableViewBuilder.swift
//  Flix
//
//  Created by DianQK on 04/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

public class AnimatableTableViewBuilder: _TableViewBuilder, PerformGroupUpdatesable {
    
    typealias AnimatableSectionModel = RxDataSources.AnimatableSectionModel<IdentifiableSectionNode, IdentifiableNode>
    
    let disposeBag = DisposeBag()
    let delegeteProxy = TableViewDelegateProxy()
    
    public let sectionProviders: BehaviorRelay<[AnimatableTableViewSectionProvider]>
    
    var nodeProviders: [_TableViewMultiNodeProvider] = [] {
        didSet {
            for provider in nodeProviders {
                provider._register(tableView)
            }
        }
    }
    var footerSectionProviders: [_SectionPartionTableViewProvider] = [] {
        didSet {
            for provider in footerSectionProviders {
                provider.register(tableView)
            }
        }
    }
    var headerSectionProviders: [_SectionPartionTableViewProvider] = [] {
        didSet {
            for provider in headerSectionProviders {
                provider.register(tableView)
            }
        }
    }

    weak var _tableView: UITableView?

    var tableView: UITableView {
        return _tableView!
    }

    public var decideViewTransition: (([ChangesetInfo]) -> ViewTransition)?

    public init(tableView: UITableView, sectionProviders: [AnimatableTableViewSectionProvider]) {
        
        self._tableView = tableView
        self.sectionProviders = BehaviorRelay(value: sectionProviders)
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel>(configureCell: { [weak self] dataSource, tableView, indexPath, node in
            guard let provider = self?.nodeProviders.first(where: { $0._flix_identity == node.providerIdentity }) else { return UITableViewCell() }
            return provider._configureCell(tableView, indexPath: indexPath, node: node)
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
                self?.footerSectionProviders = sectionProviders.compactMap { $0.animatableFooterProvider }
                self?.headerSectionProviders = sectionProviders.compactMap { $0.animatableHeaderProvider }
            })
            .flatMapLatest { (providers) -> Observable<[AnimatableSectionModel]> in
                let sections: [Observable<(section: IdentifiableSectionNode, nodes: [IdentifiableNode])?>] = providers.map { $0.createSectionModel() }
                return Observable.combineLatest(sections)
                    .ifEmpty(default: [])
                    .map { value -> [AnimatableSectionModel] in
                        return combineSections(value)
                }
            }
            .sendLatest(when: performGroupUpdatesBehaviorRelay)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

    }
    
    public convenience init(tableView: UITableView, providers: [_AnimatableTableViewMultiNodeProvider]) {
        let sectionProviderTableViewBuilder = AnimatableTableViewSectionProvider(
            providers: providers,
            headerProvider: nil,
            footerProvider: nil
        )
        self.init(tableView: tableView, sectionProviders: [sectionProviderTableViewBuilder])
    }
    
}
