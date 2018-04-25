//
//  TableViewBuilder.swift
//  Flix
//
//  Created by DianQK on 08/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

protocol CombineSectionModelType {

    associatedtype Section
    associatedtype Item

    init(model: Section, items: [Item])

}

func combineSections<S: _SectionNode, N: _Node, FlixSectionModel: CombineSectionModelType>(_ value: [(section: S, nodes: [N])?]) -> [FlixSectionModel]
    where FlixSectionModel.Item == N, FlixSectionModel.Section == S {
        return value.compactMap { $0 }.enumerated()
            .map { (offset, section) -> FlixSectionModel in
                let items = section.nodes.map { (node) -> N in
                    var node = node
                    node.providerStartIndexPath.section = offset
                    node.providerEndIndexPath.section = offset
                    return node
                }
                return FlixSectionModel.init(model: section.section, items: items)
        }

}

extension SectionModel: CombineSectionModelType { }
extension AnimatableSectionModel: CombineSectionModelType { }

public class TableViewBuilder: _TableViewBuilder, PerformGroupUpdatesable {
    
    typealias SectionModel = RxDataSources.SectionModel<SectionNode, Node>
    
    let disposeBag = DisposeBag()
    let delegeteProxy = TableViewDelegateProxy()
    
    public let sectionProviders: BehaviorRelay<[TableViewSectionProvider]>
    
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

    public init(tableView: UITableView, sectionProviders: [TableViewSectionProvider]) {
        
        self._tableView = tableView
        
        self.sectionProviders = BehaviorRelay(value: sectionProviders)
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel>(configureCell: { [weak self] dataSource, tableView, indexPath, node in
            guard let provider = self?.nodeProviders.first(where: { $0._flix_identity == node.providerIdentity }) else { return UITableViewCell() }
            return provider._configureCell(tableView, indexPath: indexPath, node: node)
        })

        self.build(dataSource: dataSource)

        self.sectionProviders.asObservable()
            .do(onNext: { [weak self] (sectionProviders) in
                self?.nodeProviders = sectionProviders.flatMap { $0.providers.flatMap { $0.__providers } }
                self?.footerSectionProviders = sectionProviders.compactMap { $0.footerProvider }
                self?.headerSectionProviders = sectionProviders.compactMap { $0.headerProvider }
            })
            .flatMapLatest { (providers) -> Observable<[SectionModel]> in
                let sections = providers.map { $0.createSectionModel() }
                return Observable.combineLatest(sections)
                    .ifEmpty(default: [])
                    .map { value -> [SectionModel] in
                        return combineSections(value)
                }
            }
            .sendLatest(when: performGroupUpdatesBehaviorRelay)
            .debounce(0, scheduler: MainScheduler.instance)
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

    }
    
    public convenience init(tableView: UITableView, providers: [_TableViewMultiNodeProvider]) {
        let sectionProviderTableViewBuilder = TableViewSectionProvider(
            providers: providers,
            headerProvider: nil,
            footerProvider: nil
        )
        self.init(tableView: tableView, sectionProviders: [sectionProviderTableViewBuilder])
    }
    
}
