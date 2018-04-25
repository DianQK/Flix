//
//  _TableViewBuilder.swift
//  Flix
//
//  Created by DianQK on 22/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

protocol _TableViewBuilder: Builder {
    
    var disposeBag: DisposeBag { get }
    var delegeteProxy: TableViewDelegateProxy { get }
    
    var tableView: UITableView { get }
    
    var nodeProviders: [String: _TableViewMultiNodeProvider] { get }
    var footerSectionProviders: [String: _SectionPartionTableViewProvider] { get }
    var headerSectionProviders: [String: _SectionPartionTableViewProvider] { get }
    
}

protocol FlixSectionModelType: SectionModelType {
    
    associatedtype Section
    
    var model: Section { get }

    init(model: Section, items: [Item])
    
}

extension AnimatableSectionModel: FlixSectionModelType { }

extension SectionModel: FlixSectionModelType { }

extension _TableViewBuilder {
    
    func build<S: FlixSectionModelType>(dataSource: TableViewSectionedDataSource<S>) where S.Item: _Node, S.Section: _SectionNode {
        dataSource.canEditRowAtIndexPath = { [weak tableView, weak self] (dataSource, indexPath) in
            guard let tableView = tableView else { return false }
            let node = dataSource[indexPath]
            guard let provider = self?.nodeProviders[node.providerIdentity] else { return false }
            if let provider = provider as? _TableViewEditable {
                return provider._tableView(tableView, canEditRowAt: indexPath, node: node)
            } else {
                return false
            }
        }
        
        dataSource.canMoveRowAtIndexPath = { [weak tableView, weak self] (dataSource, indexPath) in
            guard let tableView = tableView else { return false }
            let node = dataSource[indexPath]
            guard let provider = self?.nodeProviders[node.providerIdentity] else { return false }
            if let provider = provider as? _TableViewMoveable {
                return provider._tableView(tableView, canMoveRowAt: indexPath, node: node)
            } else {
                return false
            }
        }
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak tableView, unowned self] (indexPath) in
                guard let tableView = tableView else { return }
                let node = dataSource[indexPath]
                let provider = self.nodeProviders[node.providerIdentity]
                provider?._itemSelected(tableView, indexPath: indexPath, node: node)
            })
            .disposed(by: disposeBag)

        tableView.rx.itemDeselected
            .subscribe(onNext: { [weak tableView, unowned self] (indexPath) in
                guard let tableView = tableView else { return }
                let node = dataSource[indexPath]
                let provider = self.nodeProviders[node.providerIdentity]
                provider?._itemDeselected(tableView, indexPath: indexPath, node: node)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak tableView, unowned self] (indexPath) in
                guard let tableView = tableView else { return }
                let node = dataSource[indexPath]
                let provider = self.nodeProviders[node.providerIdentity]! as? _TableViewDeleteable
                provider?._tableView(tableView, itemDeletedForRowAt: indexPath, node: node)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemMoved
            .subscribe(onNext: { [weak tableView, unowned self] (itemMovedEvent) in
                guard let tableView = tableView else { return }
                let node = dataSource[itemMovedEvent.destinationIndex]
                guard let provider = self.nodeProviders[node.providerIdentity] as? _TableViewMoveable else { return }
                provider._tableView(
                    tableView,
                    moveRowAt: itemMovedEvent.sourceIndex.row - node.providerStartIndexPath.row,
                    to: itemMovedEvent.destinationIndex.row - node.providerStartIndexPath.row,
                    node: node
                )
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemInserted
            .subscribe(onNext: { [weak tableView, unowned self] (indexPath) in
                guard let tableView = tableView else { return }
                let node = dataSource[indexPath]
                let provider = self.nodeProviders[node.providerIdentity]! as? _TableViewInsertable
                provider?._tableView(tableView, itemInsertedForRowAt: indexPath, node: node)
            })
            .disposed(by: disposeBag)
        
        self.delegeteProxy.heightForRowAt = { [unowned self] tableView, indexPath in
            let node = dataSource[indexPath]
            let providerIdentity = node.providerIdentity
            let provider = self.nodeProviders[providerIdentity]!
            return provider._tableView(tableView, heightForRowAt: indexPath, node: node)
        }
        
        self.delegeteProxy.editActionsForRowAt = { [unowned self] tableView, indexPath in
            let node = dataSource[indexPath]
            let providerIdentity = node.providerIdentity
            let provider = self.nodeProviders[providerIdentity]!
            if let provider = provider as? _TableViewEditable {
                return provider._tableView(tableView, editActionsForRowAt: indexPath, node: node)
            } else {
                return nil
            }
        }
        
        self.delegeteProxy.targetIndexPathForMoveFromRowAt = { [unowned self] tableView, sourceIndexPath, proposedDestinationIndexPath in
            let node = dataSource[sourceIndexPath]
            let providerIdentity = node.providerIdentity
            let provider = self.nodeProviders[providerIdentity]!
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
            let node = dataSource[indexPath]
            let providerIdentity = node.providerIdentity
            let provider = self.nodeProviders[providerIdentity]!
            if let provider = provider as? _TableViewDeleteable {
                return provider._tableView(tableView, titleForDeleteConfirmationButtonForRowAt: indexPath, node: node)
            } else {
                return nil
            }
        }
        
        self.delegeteProxy.editingStyleForRowAt = { [unowned self] tableView, indexPath in
            let node = dataSource[indexPath]
            let providerIdentity = node.providerIdentity
            let provider = self.nodeProviders[providerIdentity]!
            if let provider = provider as? _TableViewEditable {
                return provider._tableView(tableView, editingStyleForRowAt: indexPath, node: node)
            } else {
                return UITableViewCellEditingStyle.none
            }
        }

        self.delegeteProxy.heightForHeaderInSection = { [unowned self] tableView, section in
            guard let headerNode = dataSource[section].model.headerNode else { return nil }
            let providerIdentity = headerNode.providerIdentity
            let provider = self.headerSectionProviders[providerIdentity]!
            return provider._tableView(tableView, heightInSection: section, node: headerNode)
        }
        
        self.delegeteProxy.viewForHeaderInSection = { [unowned self] tableView, section in
            guard let node = dataSource[section].model.headerNode else { return UIView() }
            let provider = self.headerSectionProviders[node.providerIdentity]!
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: provider._flix_identity)!
            provider._configureSection(tableView, view: view, viewInSection: section, node: node)
            return view
        }
        
        self.delegeteProxy.viewForFooterInSection = { [unowned self] tableView, section in
            guard let node = dataSource[section].model.footerNode else { return UIView() }
            let provider = self.footerSectionProviders[node.providerIdentity]!
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: provider._flix_identity)!
            provider._configureSection(tableView, view: view, viewInSection: section, node: node)
            return view
        }
        
        self.delegeteProxy.heightForFooterInSection = { [unowned self] tableView, section in
            guard let footerNode = dataSource[section].model.footerNode else { return nil }
            let providerIdentity = footerNode.providerIdentity
            let provider = self.footerSectionProviders[providerIdentity]!
            return provider._tableView(tableView, heightInSection: section, node: footerNode)
        }
        
        tableView.rx.setDelegate(self.delegeteProxy).disposed(by: disposeBag)
    }
    
}
