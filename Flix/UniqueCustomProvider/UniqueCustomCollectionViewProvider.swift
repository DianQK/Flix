//
//  UniqueCustomCollectionViewProvider.swift
//  Flix
//
//  Created by DianQK on 04/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public typealias SingleUICollectionViewCellProvider = SingleCollectionViewProvider<UICollectionViewCell>
@available(*, deprecated, renamed: "SingleUICollectionViewCellProvider")
public typealias UniqueCustomCollectionViewProvider = SingleUICollectionViewCellProvider

open class SingleCollectionViewProvider<Cell: UICollectionViewCell>: CustomProvider, UniqueAnimatableCollectionViewProvider, CustomIdentityType {

    public typealias Cell = UICollectionViewCell
    
    open let customIdentity: String

    open let contentView: UIView = NeverHitSelfView()

    open var selectedBackgroundView: UIView? {
        didSet {
            whenGetCell { [weak self] (cell) in
                guard let `self` = self else { return }
                cell.selectedBackgroundView = self.selectedBackgroundView
            }
        }
    }

    open var backgroundView: UIView? {
        didSet {
            whenGetCell { [weak self] (cell) in
                guard let `self` = self else { return }
                cell.backgroundView = self.backgroundView
            }
        }
    }

    @available(*, deprecated, renamed: "event.selectedEvent")
    public var tap: ControlEvent<()> { return self.event.selectedEvent }
    
    open var itemSize: (() -> CGSize?)?
    
    open var isHidden: Bool {
        get {
            return _isHidden.value
        }
        set {
            _isHidden.accept(newValue)
        }
    }
    private let _isHidden = BehaviorRelay(value: false)
    
    public init(customIdentity: String) {
        self.customIdentity = customIdentity
    }
    
    public init() {
        self.customIdentity = ""
    }

    open func onCreate(_ collectionView: UICollectionView, cell: Cell, indexPath: IndexPath) {
        self.onGetCell(cell)
        cell.selectedBackgroundView = self.selectedBackgroundView
        cell.backgroundView = self.backgroundView
        cell.contentView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
    }
    
    open func itemSelected(_ collectionView: UICollectionView, indexPath: IndexPath, value: SingleCollectionViewProvider) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, value: SingleCollectionViewProvider) -> CGSize? {
        return self.itemSize?()
    }
    
    open func createValues() -> Observable<[SingleCollectionViewProvider]> {
        return self._isHidden.asObservable()
            .map { [weak self] isHidden in
                guard let `self` = self, !isHidden else { return [] }
                return [self]
        }
    }

    open func register(_ collectionView: UICollectionView) {
        collectionView.register(Cell.self, forCellWithReuseIdentifier: self._flix_identity)
    }

}

extension Reactive where Base: SingleUICollectionViewCellProvider { // TODO

    public var isHidden: Binder<Bool> {
        return Binder(self.base) { provider, hidden in
            provider.isHidden = hidden
        }
    }

}
