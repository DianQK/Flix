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

public class TableViewBuilder: _TableViewBuilder {
    
    typealias SectionModel = RxDataSources.SectionModel<SectionNode, Node>
    
    let disposeBag = DisposeBag()
    let delegeteProxy = TableViewDelegateProxy()
    
    public let sectionProviders: Variable<[TableViewSectionProvider]>
    
    var nodeProviders: [_TableViewMultiNodeProvider] = [] {
        didSet {
            for provider in nodeProviders {
                provider.register(tableView)
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
    
    let tableView: UITableView

    public init(tableView: UITableView, sectionProviders: [TableViewSectionProvider]) {
        
        self.tableView = tableView
        
        self.sectionProviders = Variable(sectionProviders)
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel>(configureCell: { [weak self] dataSource, tableView, indexPath, node in
            guard let provider = self?.nodeProviders.first(where: { $0.identity == node.providerIdentity }) else { return UITableViewCell() }
            return provider._configureCell(tableView, indexPath: indexPath, node: node)
        })

        self.build(dataSource: dataSource)

        self.sectionProviders.asObservable()
            .do(onNext: { [weak self] (sectionProviders) in
                self?.nodeProviders = sectionProviders.flatMap { $0.providers }
                self?.footerSectionProviders = sectionProviders.flatMap { $0.footerProvider }
                self?.headerSectionProviders = sectionProviders.flatMap { $0.headerProvider }
            })
            .flatMapLatest { (providers) -> Observable<[SectionModel]> in
                let sections = providers.map { $0.genteralSectionModel() }
                return Observable.combineLatest(sections)
                    .ifEmpty(default: [])
                    .map { value -> [SectionModel] in
                        return value.flatMap { $0 }.enumerated()
                            .map { (offset, section) -> SectionModel in
                                let items = section.nodes.map { (node) -> Node in
                                    var node = node
                                    node.providerStartIndexPath.section = offset
                                    node.providerEndIndexPath.section = offset
                                    return node
                                }
                                return SectionModel(model: section.section, items: items)
                        }
                }
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

    }
    
    public convenience init(tableView: UITableView, providers: [_TableViewMultiNodeProvider]) {
        let sectionProviderTableViewBuilder = TableViewSectionProvider(
            identity: "Flix",
            providers: providers,
            headerProvider: nil,
            footerProvider: nil
        )
        self.init(tableView: tableView, sectionProviders: [sectionProviderTableViewBuilder])
    }
    
}
