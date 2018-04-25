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

public class TableViewBuilder: _TableViewBuilder, PerformGroupUpdatesable {
    
    typealias SectionModel = RxDataSources.SectionModel<SectionNode, Node>
    
    let disposeBag = DisposeBag()
    let delegeteProxy = TableViewDelegateProxy()
    
    public let sectionProviders: BehaviorRelay<[TableViewSectionProvider]>
    
    var nodeProviders: [String: _TableViewMultiNodeProvider] = [:] {
        didSet {
            nodeProviders.forEach { (_, provider) in
                provider._register(tableView)
            }
        }
    }
    var footerSectionProviders: [String: _SectionPartionTableViewProvider] = [:] {
        didSet {
            footerSectionProviders.forEach { (_, provider) in
                provider.register(tableView)
            }
        }
    }
    var headerSectionProviders: [String: _SectionPartionTableViewProvider] = [:] {
        didSet {
            headerSectionProviders.forEach { (_, provider) in
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
            guard let provider = self?.nodeProviders[node.providerIdentity] else { return UITableViewCell() }
            return provider._configureCell(tableView, indexPath: indexPath, node: node)
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
                let sections = providers.map { $0.createSectionModel() }
                return Observable.combineLatest(sections)
                    .ifEmpty(default: [])
                    .map { value -> [SectionModel] in
                        return BuilderTool.combineSections(value)
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
