//
//  CollectionViewSectionProvider.swift
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

public protocol _SectionCollectionViewProvider {

    var identity: String { get }
    var cellType: UICollectionReusableView.Type { get }
    var collectionElementKindSection: UICollectionElementKindSection { get }
    
    func _configureSupplementaryView(_ collectionView: UICollectionView, sectionView: UICollectionReusableView, indexPath: IndexPath, node: _Node)

    func _genteralSection() -> Observable<_Node?>
    
    func _collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeInSection section: Int, node: _Node) -> CGSize?
    
}

extension _SectionCollectionViewProvider {
    
    public func register(_ collectionView: UICollectionView) {
        collectionView.register(self.cellType, forSupplementaryViewOfKind: self.collectionElementKindSection.rawValue, withReuseIdentifier: self.identity)
    }
    
}

public protocol SectionCollectionViewProvider: _SectionCollectionViewProvider {
    
    associatedtype CellType: UICollectionReusableView
    associatedtype ValueType
    
    func configureSupplementaryView(_ collectionView: UICollectionView, sectionView: CellType, indexPath: IndexPath, node: ValueType)
    
    func genteralSection() -> Observable<ValueType?>
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeInSection section: Int, node: ValueType) -> CGSize?
    
}

extension SectionCollectionViewProvider {
    
    public var cellType: UICollectionReusableView.Type { return CellType.self }
    
    public func _configureSupplementaryView(_ collectionView: UICollectionView, sectionView: UICollectionReusableView, indexPath: IndexPath, node: _Node) {
        if let valueNode = node as? ValueNode<ValueType> {
            configureSupplementaryView(collectionView, sectionView: sectionView as! CellType, indexPath: indexPath, node: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func _genteralSection() -> Observable<_Node?> {
        let providerIdentity = self.identity
        return genteralSection().map { $0.map { ValueNode(providerIdentity: providerIdentity, value: $0) } }
    }
    
    public func _collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeInSection section: Int, node: _Node) -> CGSize? {
        if let valueNode = node as? ValueNode<ValueType> {
            return self.collectionView(collectionView, layout: collectionViewLayout, referenceSizeInSection: section, node: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeInSection section: Int, node: ValueType) -> CGSize? {
        return nil
    }
    
}

public protocol _AnimatableSectionProviderable {
    
    func _genteralAnimatableSection() -> Observable<IdentifiableNode?>
    
}

public typealias _AnimatableSectionCollectionViewProvider = _AnimatableSectionProviderable & _SectionCollectionViewProvider

public protocol AnimatableSectionCollectionViewProvider: SectionCollectionViewProvider, _AnimatableSectionCollectionViewProvider where ValueType: Equatable, ValueType: StringIdentifiableType {
    
    func genteralAnimatableSection() -> Observable<IdentifiableNode?>
    
}

extension AnimatableSectionCollectionViewProvider {
    
    public func _genteralAnimatableSection() -> Observable<IdentifiableNode?> {
        return genteralAnimatableSection()
    }
    
}

extension AnimatableSectionCollectionViewProvider {
    
    public func _configureSupplementaryView(_ collectionView: UICollectionView, sectionView: UICollectionReusableView, indexPath: IndexPath, node: _Node) {
        if let valueNode = node as? IdentifiableValueNode<ValueType> {
            configureSupplementaryView(collectionView, sectionView: sectionView as! CellType, indexPath: indexPath, node: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func _collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeInSection section: Int, node: _Node) -> CGSize? {
        if let valueNode = node as? IdentifiableValueNode<ValueType> {
            return self.collectionView(collectionView, layout: collectionViewLayout, referenceSizeInSection: section, node: valueNode.value)
        } else {
            fatalError()
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeInSection section: Int, node: ValueType) -> CGSize? {
        return nil
    }
    
    public func genteralAnimatableSection() -> Observable<IdentifiableNode?> {
        let providerIdentity = self.identity
        return genteralSection()
            .map { $0.map { IdentifiableNode(node: IdentifiableValueNode(providerIdentity: providerIdentity, value: $0)) } }
    }
    
}
