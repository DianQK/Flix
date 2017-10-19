//
//  TableViewBuilder.swift
//  Flix
//
//  Created by wc on 08/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

public class TableViewBuilder {
    
    typealias SectionModel = RxDataSources.SectionModel<SectionNode, _Node>
    
    let disposeBag = DisposeBag()
    let delegeteService = TableViewDelegateService()
    
    public let sectionProviders: Variable<[TableViewSectionProvider]>
    
    private var nodeProviders: [_TableViewMultiNodeProvider] = [] {
        didSet {
            for provider in nodeProviders {
                provider.register(tableView)
            }
        }
    }
    private var footerSectionProviders: [_SectionPartionTableViewProvider] = [] {
        didSet {
            for provider in footerSectionProviders {
                provider.register(tableView)
            }
        }
    }
    private var headerSectionProviders: [_SectionPartionTableViewProvider] = [] {
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
        
        dataSource.canEditRowAtIndexPath = { [weak tableView, weak self] (dataSource, indexPath) in
            guard let tableView = tableView else { return false }
            let node = dataSource[indexPath]
            guard let provider = self?.nodeProviders.first(where: { $0.identity == node.providerIdentity }) else { return false }
            if let provider = provider as? _TableViewEditable {
                return provider._tableView(tableView, canEditRowAt: indexPath, node: node)
            } else {
                return false
            }
        }
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak tableView, unowned self] (indexPath) in
                guard let tableView = tableView else { return }
                let node = dataSource[indexPath]
                let provider = self.nodeProviders.first(where: { $0.identity == node.providerIdentity })!
                provider._tap(tableView, indexPath: indexPath, node: node)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak tableView, unowned self] (indexPath) in
                guard let tableView = tableView else { return }
                let node = dataSource[indexPath]
                let provider = self.nodeProviders.first(where: { $0.identity == node.providerIdentity })! as? _TableViewDeleteable
                provider?._tableView(tableView, itemDeletedForRowAt: indexPath, node: node)
            })
            .disposed(by: disposeBag)
        
        self.delegeteService.heightForRowAt = { [unowned self] tableView, indexPath in
            let node = dataSource[indexPath]
            let providerIdentity = node.providerIdentity
            let provider = self.nodeProviders.first(where: { $0.identity == providerIdentity })!
            return provider._tableView(tableView, heightForRowAt: indexPath, node: node)
        }
        
        self.delegeteService.heightForHeaderInSection = { [unowned self] tableView, section in
            guard let headerNode = dataSource[section].model.headerNode else { return nil }
            let providerIdentity = headerNode.providerIdentity
            let provider = self.headerSectionProviders.first(where: { $0.identity == providerIdentity })!
            return provider._tableView(tableView, heightInSection: section, node: headerNode)
        }
        
        self.delegeteService.viewForHeaderInSection = { [unowned self] tableView, section in
            guard let node = dataSource[section].model.headerNode else { return UIView() }
            let provider = self.headerSectionProviders.first(where: { $0.identity == node.providerIdentity })!
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: provider.identity)!
            provider._configureSection(tableView, view: view, viewInSection: section, node: node)
            return view
        }
        
        self.delegeteService.viewForFooterInSection = { [unowned self] tableView, section in
            guard let node = dataSource[section].model.footerNode else { return UIView() }
            let provider = self.footerSectionProviders.first(where: { $0.identity == node.providerIdentity })!
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: provider.identity)!
            provider._configureSection(tableView, view: view, viewInSection: section, node: node)
            return view
        }
        
        self.delegeteService.heightForFooterInSection = { [unowned self] tableView, section in
            guard let footerNode = dataSource[section].model.footerNode else { return nil }
            let providerIdentity = footerNode.providerIdentity
            let provider = self.footerSectionProviders.first(where: { $0.identity == providerIdentity })!
            return provider._tableView(tableView, heightInSection: section, node: footerNode)
        }
        
        self.delegeteService.editActionsForRowAt = { [unowned self] tableView, indexPath in
            let node = dataSource[indexPath]
            let providerIdentity = node.providerIdentity
            let provider = self.nodeProviders.first(where: { $0.identity == providerIdentity })!
            if let provider = provider as? _TableViewEditable {
                return provider._tableView(tableView, editActionsForRowAt: indexPath, node: node)
            } else {
                return nil
            }
        }
        
        tableView.rx.setDelegate(self.delegeteService).disposed(by: disposeBag)
        
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
