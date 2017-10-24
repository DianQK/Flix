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

protocol _CollectionViewBuilder: class {
    
    var disposeBag: DisposeBag { get }
    var delegeteProxy: CollectionViewDelegateProxy { get }
    
    var collectionView: UICollectionView { get }
    
    var nodeProviders: [_CollectionViewMultiNodeProvider] { get }
    var footerSectionProviders: [_SectionPartionCollectionViewProvider] { get }
    var headerSectionProviders: [_SectionPartionCollectionViewProvider] { get }
    
}

extension _CollectionViewBuilder {
    
    func build<S: FlixSectionModelType>(dataSource: CollectionViewSectionedDataSource<S>) where S.Item: _Node, S.Section: _SectionNode {
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak collectionView, unowned self] (indexPath) in
                guard let `collectionView` = collectionView else { return }
                let node = dataSource[indexPath]
                let provider = self.nodeProviders.first(where: { $0._flix_identity == node.providerIdentity })!
                provider._tap(collectionView, indexPath: indexPath, node: node)
            })
            .disposed(by: disposeBag)
        
        self.delegeteProxy.sizeForItem = { [unowned self] collectionView, flowLayout, indexPath in
            let node = dataSource[indexPath]
            let providerIdentity = node.providerIdentity
            let provider = self.nodeProviders.first(where: { $0._flix_identity == providerIdentity })!
            return provider._collectionView(collectionView, layout: flowLayout, sizeForItemAt: indexPath, node: node)
        }
        
        self.delegeteProxy.referenceSizeForFooterInSection = { [unowned self] collectionView, collectionViewLayout, section in
            guard let footerNode = dataSource[section].model.footerNode else { return CGSize.zero }
            let providerIdentity = footerNode.providerIdentity
            let provider = self.footerSectionProviders.first(where: { $0._flix_identity == providerIdentity })!
            return provider._collectionView(collectionView, layout: collectionViewLayout, referenceSizeInSection: section, node: footerNode)
        }
        
        self.delegeteProxy.referenceSizeForHeaderInSection = { [unowned self] collectionView, collectionViewLayout, section in
            guard let footerNode = dataSource[section].model.headerNode else { return CGSize.zero }
            let providerIdentity = footerNode.providerIdentity
            let provider = self.headerSectionProviders.first(where: { $0._flix_identity == providerIdentity })!
            return provider._collectionView(collectionView, layout: collectionViewLayout, referenceSizeInSection: section, node: footerNode)
        }
        
        collectionView.rx.setDelegate(self.delegeteProxy).disposed(by: disposeBag)
    }

}
