//
//  UniqueCustomCollectionViewProvider.swift
//  Flix
//
//  Created by DianQK on 04/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift

open class UniqueCustomCollectionViewProvider: UniqueAnimatableCollectionViewProvider {

    open let identity: String
    open let contentView = UIView()
    open var selectedBackgroundView: UIView?
    open var backgroundView: UIView?
    
    public var tap: Observable<()> { return _tap.asObservable() }
    private let _tap = PublishSubject<()>()
    
    open var itemSize: (() -> CGSize?)?
    
    public let isHidden = Variable(false)
    
    public init(identity: String) {
        self.identity = identity
    }

    open func onCreate(_ collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: IndexPath) {
        cell.selectedBackgroundView = self.selectedBackgroundView
        cell.backgroundView = self.backgroundView
        cell.contentView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
    }
    
    open func tap(_ collectionView: UICollectionView, indexPath: IndexPath, value: UniqueCustomCollectionViewProvider) {
        _tap.onNext(())
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, value: UniqueCustomCollectionViewProvider) -> CGSize? {
        return self.itemSize?()
    }
    
    open func genteralValues() -> Observable<[UniqueCustomCollectionViewProvider]> {
        return self.isHidden.asObservable()
            .map { [weak self] isHidden in
                guard let `self` = self, !isHidden else { return [] }
                return [self]
        }
    }
    
}
