//
//  _CollectionViewBuilder.swift
//  Flix
//
//  Created by DianQK on 22/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

protocol _CollectionViewBuilder: Builder {
    
    var disposeBag: DisposeBag { get }
    var delegeteProxy: CollectionViewDelegateProxy { get }
    
    var collectionView: UICollectionView { get }
    
    var nodeProviders: [String: _CollectionViewMultiNodeProvider] { get }
    var footerSectionProviders: [String: _SectionPartionCollectionViewProvider] { get }
    var headerSectionProviders: [String: _SectionPartionCollectionViewProvider] { get }
    
}

extension _CollectionViewBuilder {
    
    func build<S: FlixSectionModelType>(dataSource: CollectionViewSectionedDataSource<S>) where S.Item: _Node, S.Section: _SectionNode {
        dataSource.canMoveItemAtIndexPath = { [weak collectionView, weak self] (dataSource, indexPath) in
            guard let collectionView = collectionView else { return false }
            let node = dataSource[indexPath]
            guard let provider = self?.nodeProviders[node.providerIdentity] else { return false }
            if let provider = provider as? _CollectionViewMoveable {
                return provider._collectionView(collectionView, canMoveItemAt: indexPath, node: node)
            } else {
                return false
            }
        }

        dataSource.moveItem = { [weak collectionView, weak self] (dataSource, sourceIndexPath, destinationIndexPath) in
            guard let collectionView = collectionView else { return }
            let node = dataSource[destinationIndexPath]
            guard let provider = self?.nodeProviders[node.providerIdentity] as? _CollectionViewMoveable else { return }
            provider._collectionView(
                collectionView,
                moveItemAt: sourceIndexPath.row - node.providerStartIndexPath.row,
                to: destinationIndexPath.row - node.providerStartIndexPath.row,
                node: node
            )
        }

        self.delegeteProxy.targetIndexPathForMoveFromItemAt = { [weak self] (collectionView, originalIndexPath, proposedIndexPath) -> IndexPath in
            let node = dataSource[originalIndexPath]
            let providerIdentity = node.providerIdentity
            let provider = self?.nodeProviders[providerIdentity]!
            if let _ = provider as? _CollectionViewMoveable {
                if (proposedIndexPath <= node.providerStartIndexPath) {
                    return node.providerStartIndexPath
                } else if (proposedIndexPath >= node.providerEndIndexPath) {
                    return node.providerEndIndexPath
                } else {
                    return proposedIndexPath
                }
            } else {
                return proposedIndexPath
            }
        }

        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak collectionView, unowned self] (indexPath) in
                guard let `collectionView` = collectionView else { return }
                let node = dataSource[indexPath]
                let provider = self.nodeProviders[node.providerIdentity]!
                provider._itemSelected(collectionView, indexPath: indexPath, node: node)
            })
            .disposed(by: disposeBag)

        collectionView.rx.itemDeselected
            .subscribe(onNext: { [weak collectionView, unowned self] (indexPath) in
                guard let `collectionView` = collectionView else { return }
                let node = dataSource[indexPath]
                let provider = self.nodeProviders[node.providerIdentity]!
                provider._itemDeselected(collectionView, indexPath: indexPath, node: node)
            })
            .disposed(by: disposeBag)
        
        self.delegeteProxy.sizeForItem = { [unowned self] collectionView, flowLayout, indexPath in
            let node = dataSource[indexPath]
            let providerIdentity = node.providerIdentity
            let provider = self.nodeProviders[providerIdentity]!
            return provider._collectionView(collectionView, layout: flowLayout, sizeForItemAt: indexPath, node: node)
        }

        self.delegeteProxy.shouldSelectItemAt = { [unowned self] collectionView, indexPath in
            let node = dataSource[indexPath]
            let providerIdentity = node.providerIdentity
            let provider = self.nodeProviders[providerIdentity]!
            return provider._collectionView(collectionView, shouldSelectItemAt: indexPath, node: node)
        }
        
        self.delegeteProxy.referenceSizeForFooterInSection = { [unowned self] collectionView, collectionViewLayout, section in
            guard let footerNode = dataSource[section].model.footerNode else { return CGSize.zero }
            let providerIdentity = footerNode.providerIdentity
            let provider = self.footerSectionProviders[providerIdentity]!
            return provider._collectionView(collectionView, layout: collectionViewLayout, referenceSizeInSection: section, node: footerNode)
        }
        
        self.delegeteProxy.referenceSizeForHeaderInSection = { [unowned self] collectionView, collectionViewLayout, section in
            guard let footerNode = dataSource[section].model.headerNode else { return CGSize.zero }
            let providerIdentity = footerNode.providerIdentity
            let provider = self.headerSectionProviders[providerIdentity]!
            return provider._collectionView(collectionView, layout: collectionViewLayout, referenceSizeInSection: section, node: footerNode)
        }
        
        collectionView.rx.setDelegate(self.delegeteProxy).disposed(by: disposeBag)
    }

}
