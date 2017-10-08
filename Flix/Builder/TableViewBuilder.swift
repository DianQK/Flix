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
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel>()
    let disposeBag = DisposeBag()
    let delegeteService = TableViewDelegateService()

    public init(tableView: UITableView, sectionProviders: [TableViewSectionProvider]) {
        
        let nodeProviders: [_TableViewMultiNodeProvider] = sectionProviders.flatMap { $0.providers }
        let footerSectionProviders: [_SectionPartionTableViewProvider] = sectionProviders.flatMap { $0.footerProvider }
        let headerSectionProviders: [_SectionPartionTableViewProvider] = sectionProviders.flatMap { $0.headerProvider }
        
        dataSource.configureCell = { dataSource, tableView, indexPath, node in
            let provider = nodeProviders.first(where: { $0.identity == node.providerIdentity })!
            return provider._configureCell(tableView, indexPath: indexPath, node: node)
        }
        
        dataSource.canEditRowAtIndexPath = { [weak tableView] (dataSource, indexPath) in
            guard let tableView = tableView else { return false }
            let node = dataSource[indexPath]
            let provider = nodeProviders.first(where: { $0.identity == node.providerIdentity })!
            if let provider = provider as? _TableViewEditable {
                return provider._tableView(tableView, canEditRowAt: indexPath, node: node)
            } else {
                return false
            }
        }
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak tableView, unowned self] (indexPath) in
                guard let tableView = tableView else { return }
                let node = self.dataSource[indexPath]
                let provider = nodeProviders.first(where: { $0.identity == node.providerIdentity })!
                provider._tap(tableView, indexPath: indexPath, node: node)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak tableView, unowned self] (indexPath) in
                guard let tableView = tableView else { return }
                let node = self.dataSource[indexPath]
                let provider = nodeProviders.first(where: { $0.identity == node.providerIdentity })! as? _TableViewDeleteable
                provider?._tableView(tableView, itemDeletedForRowAt: indexPath, node: node)
            })
            .disposed(by: disposeBag)
        
        for provider in nodeProviders {
            provider.register(tableView)
        }
        
        for provider in footerSectionProviders {
            provider.register(tableView)
        }
        
        for provider in headerSectionProviders {
            provider.register(tableView)
        }
        
        self.delegeteService.heightForRowAt = { [weak self] tableView, indexPath in
            guard let node = self?.dataSource[indexPath] else { return nil }
            let providerIdentity = node.providerIdentity
            let provider = nodeProviders.first(where: { $0.identity == providerIdentity })!
            return provider._tableView(tableView, heightForRowAt: indexPath, node: node)
        }
        
        self.delegeteService.heightForHeaderInSection = { [weak self] tableView, section in
            guard let headerNode = self?.dataSource[section].model.headerNode else { return nil }
            let providerIdentity = headerNode.providerIdentity
            let provider = headerSectionProviders.first(where: { $0.identity == providerIdentity })!
            return provider._tableView(tableView, heightInSection: section, node: headerNode)
        }
        
        self.delegeteService.viewForHeaderInSection = { [weak self] tableView, section in
            guard let node = self?.dataSource[section].model.headerNode else { return UIView() }
            let provider = headerSectionProviders.first(where: { $0.identity == node.providerIdentity })!
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: provider.identity)!
            provider._configureSection(tableView, view: view, viewInSection: section, node: node)
            return view
        }
        
        self.delegeteService.viewForFooterInSection = { [weak self] tableView, section in
            guard let node = self?.dataSource[section].model.footerNode else { return UIView() }
            let provider = footerSectionProviders.first(where: { $0.identity == node.providerIdentity })!
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: provider.identity)!
            provider._configureSection(tableView, view: view, viewInSection: section, node: node)
            return view
        }
        
        self.delegeteService.heightForFooterInSection = { [weak self] tableView, section in
            guard let footerNode = self?.dataSource[section].model.footerNode else { return nil }
            let providerIdentity = footerNode.providerIdentity
            let provider = footerSectionProviders.first(where: { $0.identity == providerIdentity })!
            return provider._tableView(tableView, heightInSection: section, node: footerNode)
        }
        
        self.delegeteService.editActionsForRowAt = { [weak self] tableView, indexPath in
            guard let node = self?.dataSource[indexPath] else { return nil }
            let providerIdentity = node.providerIdentity
            let provider = nodeProviders.first(where: { $0.identity == providerIdentity })!
            if let provider = provider as? _TableViewEditable {
                return provider._tableView(tableView, editActionsForRowAt: indexPath, node: node)
            } else {
                return nil
            }
        }
        
        tableView.rx.setDelegate(self.delegeteService).disposed(by: disposeBag)
        
        Observable.combineLatest(sectionProviders.map { $0.genteralSectionModel() })
            .map { $0.map { SectionModel(model: $0.section, items: $0.nodes) } }
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
