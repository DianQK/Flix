//
//  UniqueCustomCollectionViewSectionProvider.swift
//  Flix
//
//  Created by DianQK on 06/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

open class UniqueCustomCollectionViewSectionProvider: AnimatableSectionPartionCollectionViewProvider, StringIdentifiableType, Equatable {
    
    public var identity: String {
        return self._flix_identity
    }

    open let customIdentity: String
    open let collectionElementKindSection: UICollectionElementKindSection
    
    public typealias Cell = UICollectionReusableView
    public typealias Value = UniqueCustomCollectionViewSectionProvider

    open var isHidden: Bool {
        get {
            return _isHidden.value
        }
        set {
            _isHidden.accept(newValue)
        }
    }
    private let _isHidden = BehaviorRelay(value: false)
    
    open var sectionSize: ((UICollectionView) -> CGSize)?
    
    open let contentView: UIView = NeverHitSelfView()
    
    public init(customIdentity: String, collectionElementKindSection: UICollectionElementKindSection) {
        self.customIdentity = customIdentity
        self.collectionElementKindSection = collectionElementKindSection
    }
    
    public init(collectionElementKindSection: UICollectionElementKindSection) {
        self.customIdentity = ""
        self.collectionElementKindSection = collectionElementKindSection
    }
    
    public static func ==(lhs: UniqueCustomCollectionViewSectionProvider, rhs: UniqueCustomCollectionViewSectionProvider) -> Bool {
        return true
    }
    
    open func configureSupplementaryView(_ collectionView: UICollectionView, sectionView: Cell, indexPath: IndexPath, value: Value) {
        sectionView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: sectionView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: sectionView.bottomAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor).isActive = true
    }
    
    open func createSectionPartion() -> Observable<Value?> {
        return self._isHidden.asObservable()
            .map { [weak self] isHidden in
                return isHidden ? nil : self
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeInSection section: Int, value: Value) -> CGSize? {
        return sectionSize?(collectionView)
    }

}

extension Reactive where Base: UniqueCustomCollectionViewSectionProvider {

    public var isHidden: Binder<Bool> {
        return Binder(self.base) { provider, hidden in
            provider.isHidden = hidden
        }
    }

}
