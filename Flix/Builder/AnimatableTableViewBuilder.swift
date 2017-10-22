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

public class AnimatableTableViewBuilder {
    
    typealias AnimatableSectionModel = RxDataSources.AnimatableSectionModel<IdentifiableSectionNode, IdentifiableNode>
    
    let disposeBag = DisposeBag()
    let delegeteProxy = TableViewDelegateProxy()
    
    let tableView: UITableView
    
    public let sectionProviders: Variable<[AnimatableTableViewSectionProvider]>
    
    private var nodeProviders: [_AnimatableTableViewMultiNodeProvider] = [] {
        didSet {
            for provider in nodeProviders {
                provider.register(tableView)
            }
        }
    }
    private var footerSectionProviders: [_AnimatableSectionPartionTableViewProvider] = [] {
        didSet {
            for provider in footerSectionProviders {
                provider.register(tableView)
            }
        }
    }
    private var headerSectionProviders: [_AnimatableSectionPartionTableViewProvider] = [] {
        didSet {
            for provider in headerSectionProviders {
                provider.register(tableView)
            }
        }
    }

    public init(tableView: UITableView, sectionProviders: [AnimatableTableViewSectionProvider]) {
        
        self.tableView = tableView
        self.sectionProviders = Variable(sectionProviders)
        
        let dataSource = RxTableViewSectionedAnimatedDataSource<AnimatableSectionModel>(configureCell: { [weak self] dataSource, tableView, indexPath, node in
            guard let provider = self?.nodeProviders.first(where: { $0.identity == node.node.providerIdentity }) else { return UITableViewCell() }
            return provider._configureCell(tableView, indexPath: indexPath, node: node.node)
        })
        
        dataSource.animationConfiguration = AnimationConfiguration(
            insertAnimation: .fade,
            reloadAnimation: .none,
            deleteAnimation: .fade
        )
        
        dataSource.canEditRowAtIndexPath = { [weak tableView, weak self] (dataSource, indexPath) in
            guard let tableView = tableView else { return false }
            let node = dataSource[indexPath]
            guard let provider = self?.nodeProviders.first(where: { $0.identity == node.node.providerIdentity }) else { return false } 
            if let provider = provider as? _TableViewEditable {
                return provider._tableView(tableView, canEditRowAt: indexPath, node: node.node)
            } else {
                return false
            }
        }
        
        dataSource.canMoveRowAtIndexPath = { [weak tableView, weak self] (dataSource, indexPath) in
            guard let tableView = tableView else { return false }
            let node = dataSource[indexPath]
            guard let provider = self?.nodeProviders.first(where: { $0.identity == node.node.providerIdentity }) else { return false }
            if let provider = provider as? _TableViewMoveable {
                return provider._tableView(tableView, canMoveRowAt: indexPath, node: node.node)
            } else {
                return false
            }
        }

        tableView.rx.itemSelected
            .subscribe(onNext: { [weak tableView, unowned self] (indexPath) in
                guard let tableView = tableView else { return }
                let node = dataSource[indexPath].node
                let provider = self.nodeProviders.first(where: { $0.identity == node.providerIdentity })!
                provider._tap(tableView, indexPath: indexPath, node: node)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak tableView, unowned self] (indexPath) in
                guard let tableView = tableView else { return }
                let node = dataSource[indexPath].node
                let provider = self.nodeProviders.first(where: { $0.identity == node.providerIdentity })! as? _TableViewDeleteable
                provider?._tableView(tableView, itemDeletedForRowAt: indexPath, node: node)
            })
            .disposed(by: disposeBag)

        tableView.rx.itemMoved
            .subscribe(onNext: { [weak tableView, unowned self] (itemMovedEvent) in
                guard let tableView = tableView else { return }
                let node = dataSource[itemMovedEvent.destinationIndex]
                guard let provider = self.nodeProviders.first(where: { $0.identity == node.node.providerIdentity }) as? _TableViewMoveable else { return }
                provider._tableView(
                    tableView,
                    moveRowAt: itemMovedEvent.sourceIndex.row - node.providerStartIndexPath.row,
                    to: itemMovedEvent.destinationIndex.row - node.providerStartIndexPath.row,
                    node: node.node
                )
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemInserted
            .subscribe(onNext: { [weak tableView, unowned self] (indexPath) in
                guard let tableView = tableView else { return }
                let node = dataSource[indexPath].node
                let provider = self.nodeProviders.first(where: { $0.identity == node.providerIdentity })! as? _TableViewInsertable
                provider?._tableView(tableView, itemInsertedForRowAt: indexPath, node: node)
            })
            .disposed(by: disposeBag)

        self.delegeteProxy.heightForRowAt = { [unowned self] tableView, indexPath in
            let node = dataSource[indexPath].node
            let providerIdentity = node.providerIdentity
            let provider = self.nodeProviders.first(where: { $0.identity == providerIdentity })!
            return provider._tableView(tableView, heightForRowAt: indexPath, node: node)
        }
        
        self.delegeteProxy.heightForHeaderInSection = { [unowned self] tableView, section in
            guard let headerNode = dataSource[section].model.headerNode?.node else { return nil }
            let providerIdentity = headerNode.providerIdentity
            let provider = self.headerSectionProviders.first(where: { $0.identity == providerIdentity })!
            return provider._tableView(tableView, heightInSection: section, node: headerNode)
        }
        
        self.delegeteProxy.viewForHeaderInSection = { [unowned self] tableView, section in
            guard let node = dataSource[section].model.headerNode else { return UIView() }
            let provider = self.headerSectionProviders.first(where: { $0.identity == node.node.providerIdentity })!
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: provider.identity)!
            provider._configureSection(tableView, view: view, viewInSection: section, node: node.node)
            return view
        }

        self.delegeteProxy.viewForFooterInSection = { [unowned self] tableView, section in
            guard let node = dataSource[section].model.footerNode else { return UIView() }
            let provider = self.footerSectionProviders.first(where: { $0.identity == node.node.providerIdentity })!
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: provider.identity)!
            provider._configureSection(tableView, view: view, viewInSection: section, node: node.node)
            return view
        }
        
        self.delegeteProxy.heightForFooterInSection = { [unowned self] tableView, section in
            guard let footerNode = dataSource[section].model.footerNode?.node else { return nil }
            let providerIdentity = footerNode.providerIdentity
            let provider = self.footerSectionProviders.first(where: { $0.identity == providerIdentity })!
            return provider._tableView(tableView, heightInSection: section, node: footerNode)
        }
        
        self.delegeteProxy.editActionsForRowAt = { [unowned self] tableView, indexPath in
            let node = dataSource[indexPath].node
            let providerIdentity = node.providerIdentity
            let provider = self.nodeProviders.first(where: { $0.identity == providerIdentity })!
            if let provider = provider as? _TableViewEditable {
                return provider._tableView(tableView, editActionsForRowAt: indexPath, node: node)
            } else {
                return nil
            }
        }
        
        self.delegeteProxy.targetIndexPathForMoveFromRowAt = { [unowned self] tableView, sourceIndexPath, proposedDestinationIndexPath in
            let node = dataSource[sourceIndexPath]
            let providerIdentity = node.node.providerIdentity
            let provider = self.nodeProviders.first(where: { $0.identity == providerIdentity })!
            if let _ = provider as? _TableViewMoveable {
                if (proposedDestinationIndexPath <= node.providerStartIndexPath) {
                    return node.providerStartIndexPath
                } else if (proposedDestinationIndexPath >= node.providerEndIndexPath) {
                    return node.providerEndIndexPath
                } else {
                    return proposedDestinationIndexPath
                }
            } else {
                return proposedDestinationIndexPath
            }
        }
        
        self.delegeteProxy.titleForDeleteConfirmationButtonForRowAt = { [unowned self] tableView, indexPath in
            let node = dataSource[indexPath].node
            let providerIdentity = node.providerIdentity
            let provider = self.nodeProviders.first(where: { $0.identity == providerIdentity })!
            if let provider = provider as? _TableViewDeleteable {
                return provider._tableView(tableView, titleForDeleteConfirmationButtonForRowAt: indexPath, node: node)
            } else {
                return nil
            }
        }
        
        self.delegeteProxy.editingStyleForRowAt = { [unowned self] tableView, indexPath in
            let node = dataSource[indexPath].node
            let providerIdentity = node.providerIdentity
            let provider = self.nodeProviders.first(where: { $0.identity == providerIdentity })!
            if let provider = provider as? _TableViewEditable {
                return provider._tableView(tableView, editingStyleForRowAt: indexPath, node: node)
            } else {
                return UITableViewCellEditingStyle.none
            }
        }
        
        tableView.rx.setDelegate(self.delegeteProxy).disposed(by: disposeBag)
        
        self.sectionProviders.asObservable()
            .do(onNext: { [weak self] (sectionProviders) in
                self?.nodeProviders = sectionProviders.flatMap { $0.animatableProviders }
                self?.footerSectionProviders = sectionProviders.flatMap { $0.animatableFooterProvider }
                self?.headerSectionProviders = sectionProviders.flatMap { $0.animatableHeaderProvider }
            })
            .flatMapLatest { (providers) -> Observable<[AnimatableSectionModel]> in
                let sections: [Observable<(section: IdentifiableSectionNode, nodes: [IdentifiableNode])?>] = providers.map { $0.genteralAnimatableSectionModel() }
                return Observable.combineLatest(sections)
                    .map { value -> [AnimatableSectionModel] in
                        return value.flatMap { $0 }.enumerated()
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
                    .ifEmpty(default: [])
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

    }
    
    public convenience init(tableView: UITableView, providers: [_AnimatableTableViewMultiNodeProvider]) {
        let sectionProviderTableViewBuilder = AnimatableTableViewSectionProvider(
            identity: "Flix",
            providers: providers,
            headerProvider: nil,
            footerProvider: nil
        )
        self.init(tableView: tableView, sectionProviders: [sectionProviderTableViewBuilder])
    }
    
}
