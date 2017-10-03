//
//  AnimatableTableViewService.swift
//  Flix
//
//  Created by DianQK on 04/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

public class AnimatableTableViewService {
    
    typealias AnimatableSectionModel = RxDataSources.AnimatableSectionModel<IdentifiableSectionNode, IdentifiableNode>
    
    let dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel>()
    let disposeBag = DisposeBag()
    let delegeteService = TableViewDelegateService()
    
    public init(tableView: UITableView, sectionProviderBuilders: [SectionProviderTableViewBuilder]) {
        
        dataSource.animationConfiguration = AnimationConfiguration(
            insertAnimation: .fade,
            reloadAnimation: .fade,
            deleteAnimation: .fade
        )

        let nodeProviders: [_AnimatableTableViewProvider] = sectionProviderBuilders.flatMap { $0.providers }
        let footerSectionProviders: [_AnimatableSectionTableViewProvider] = sectionProviderBuilders.flatMap { $0.footerProvider }
        let headerSectionProviders: [_AnimatableSectionTableViewProvider] = sectionProviderBuilders.flatMap { $0.headerProvider }
        
        dataSource.configureCell = { dataSource, tableView, indexPath, node in
            let provider = nodeProviders.first(where: { $0.identity == node.node.providerIdentity })!
            let cell = tableView.dequeueReusableCell(withIdentifier: provider.identity, for: indexPath)
            provider._configureCell(tableView, cell: cell, indexPath: indexPath, node: node.node)
            return cell
        }

        tableView.rx.itemSelected
            .subscribe(onNext: { [weak tableView, unowned self] (indexPath) in
                guard let tableView = tableView else { return }
                let node = self.dataSource[indexPath].node
                let provider = nodeProviders.first(where: { $0.identity == node.providerIdentity })!
                provider._tap(tableView, indexPath: indexPath, node: node)
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
            guard let node = self?.dataSource[indexPath].node else { return nil }
            let providerIdentity = node.providerIdentity
            let provider = nodeProviders.first(where: { $0.identity == providerIdentity })!
            return provider._tableView(tableView, heightForRowAt: indexPath, node: node)
        }
        
        self.delegeteService.heightForHeaderInSection = { [weak self] tableView, section in
            guard let headerNode = self?.dataSource[section].model.headerNode?.node else { return nil }
            let providerIdentity = headerNode.providerIdentity
            let provider = headerSectionProviders.first(where: { $0.identity == providerIdentity })!
            return provider._tableView(tableView, heightInSection: section, node: headerNode)
        }
        
        self.delegeteService.viewForHeaderInSection = { [weak self] tableView, section in
            guard let node = self?.dataSource[section].model.headerNode else { return UIView() }
            let provider = headerSectionProviders.first(where: { $0.identity == node.node.providerIdentity })!
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: provider.identity)!
            provider._configureSection(tableView, view: view, viewInSection: section, node: node.node)
            return view
        }

        self.delegeteService.viewForFooterInSection = { [weak self] tableView, section in
            guard let node = self?.dataSource[section].model.footerNode else { return UIView() }
            let provider = footerSectionProviders.first(where: { $0.identity == node.node.providerIdentity })!
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: provider.identity)!
            provider._configureSection(tableView, view: view, viewInSection: section, node: node.node)
            return view
        }
        
        self.delegeteService.heightForFooterInSection = { [weak self] tableView, section in
            guard let footerNode = self?.dataSource[section].model.footerNode?.node else { return nil }
            let providerIdentity = footerNode.providerIdentity
            let provider = footerSectionProviders.first(where: { $0.identity == providerIdentity })!
            return provider._tableView(tableView, heightInSection: section, node: footerNode)
        }
        
        tableView.rx.setDelegate(self.delegeteService).disposed(by: disposeBag)
        
        Observable.combineLatest(sectionProviderBuilders.map { $0.genteralSectionModel() })
            .map { $0.map { AnimatableSectionModel(model: $0.section, items: $0.nodes) } }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    public convenience init(tableView: UITableView, providers: [_AnimatableTableViewProvider]) {
        let sectionProviderTableViewBuilder = SectionProviderTableViewBuilder(
            identity: "Flix",
            providers: providers,
            headerProvider: nil,
            footerProvider: nil
        )
        self.init(tableView: tableView, sectionProviderBuilders: [sectionProviderTableViewBuilder])
    }
    
}

class TableViewDelegateService: NSObject, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heightForRowAt?(tableView, indexPath) ?? tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.heightForHeaderInSection?(tableView, section) ?? tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.viewForHeaderInSection?(tableView, section)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.heightForFooterInSection?(tableView, section) ?? tableView.sectionFooterHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.viewForFooterInSection?(tableView, section)
    }
    
    var heightForRowAt: ((_ tableView: UITableView, _ indexPath: IndexPath) -> CGFloat?)?
    var heightForFooterInSection: ((_ tableView: UITableView, _ section: Int) -> CGFloat?)?
    var heightForHeaderInSection: ((_ tableView: UITableView, _ section: Int) -> CGFloat?)?
    var viewForHeaderInSection: ((_ tableView: UITableView, _ section: Int) -> UIView?)?
    var viewForFooterInSection: ((_ tableView: UITableView, _ section: Int) -> UIView?)?
    
}
