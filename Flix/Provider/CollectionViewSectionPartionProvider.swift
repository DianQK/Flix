//
//  CollectionViewSectionPartionProvider.swift
//  Flix
//
//  Created by DianQK on 03/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

public enum UICollectionElementKindSection: String {

    case header = "UICollectionElementKindSectionHeader"
    case footer = "UICollectionElementKindSectionFooter"

}

public protocol _SectionPartionCollectionViewProvider: FlixCustomStringConvertible {

    var cellType: UICollectionReusableView.Type { get }
    var collectionElementKindSection: UICollectionElementKindSection { get }

    func _configureSupplementaryView(_ collectionView: UICollectionView, sectionView: UICollectionReusableView, indexPath: IndexPath, node: _Node)

    func _createSectionPartion() -> Observable<_Node?>
    
    func _collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeInSection section: Int, node: _Node) -> CGSize?
    
}

extension _SectionPartionCollectionViewProvider {
    
    public func register(_ collectionView: UICollectionView) {
        collectionView.register(self.cellType, forSupplementaryViewOfKind: self.collectionElementKindSection.rawValue, withReuseIdentifier: self._flix_identity)
    }
    
}

public protocol SectionPartionCollectionViewProvider: _SectionPartionCollectionViewProvider, ReactiveCompatible {
    
    associatedtype Cell: UICollectionReusableView
    associatedtype Value
    
    func configureSupplementaryView(_ collectionView: UICollectionView, sectionView: Cell, indexPath: IndexPath, value: Value)
    
    func createSectionPartion() -> Observable<Value?>
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeInSection section: Int, value: Value) -> CGSize?
    
}

extension SectionPartionCollectionViewProvider {
    
    public var cellType: UICollectionReusableView.Type { return Cell.self }
    
    public func _configureSupplementaryView(_ collectionView: UICollectionView, sectionView: UICollectionReusableView, indexPath: IndexPath, node: _Node) {
        return configureSupplementaryView(collectionView, sectionView: sectionView as! Cell, indexPath: indexPath, value: node._unwarp())
    }
    
    public func _createSectionPartion() -> Observable<_Node?> {
        let providerIdentity = self._flix_identity
        return createSectionPartion().map { $0.map { Node(providerIdentity: providerIdentity, value: $0) } }
    }
    
    public func _collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeInSection section: Int, node: _Node) -> CGSize? {
        return self.collectionView(collectionView, layout: collectionViewLayout, referenceSizeInSection: section, value: node._unwarp())
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeInSection section: Int, value: Value) -> CGSize? {
        return nil
    }
    
}

public typealias _AnimatableSectionPartionCollectionViewProvider = _AnimatableSectionPartionProviderable & _SectionPartionCollectionViewProvider

public protocol AnimatableSectionPartionCollectionViewProvider: SectionPartionCollectionViewProvider, _AnimatableSectionPartionProviderable where Value: Equatable, Value: StringIdentifiableType {
    
    func createAnimatableSection() -> Observable<IdentifiableNode?>
    
}

extension AnimatableSectionPartionCollectionViewProvider {
    
    public func _createAnimatableSectionPartion() -> Observable<IdentifiableNode?> {
        return createAnimatableSection()
    }

    public var identity: String {
        return self._flix_identity
    }
    
}

extension AnimatableSectionPartionCollectionViewProvider {
    
    public func createAnimatableSection() -> Observable<IdentifiableNode?> {
        let providerIdentity = self._flix_identity
        return createSectionPartion().map { $0.map { IdentifiableNode(providerIdentity: providerIdentity, valueNode: $0) } }
    }
    
}
