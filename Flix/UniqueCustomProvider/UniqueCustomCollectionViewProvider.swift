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

open class UniqueCustomCollectionViewProvider: UniqueAnimatableCollectionViewProvider, CustomIdentityType {
    
    open let customIdentity: String

    open let contentView: UIView = NeverHitSelfView()

    open var selectedBackgroundView: UIView? {
        didSet {
            _cell?.selectedBackgroundView = selectedBackgroundView
        }
    }

    open var backgroundView: UIView? {
        didSet {
            _cell?.backgroundView = backgroundView
        }
    }
    
    public var tap: ControlEvent<()> { return ControlEvent(events: _tap.asObservable()) }

    private let _tap = PublishSubject<()>()
    
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

    open var isEnabled = true

    private weak var _cell: UICollectionViewCell?
    
    public init(customIdentity: String) {
        self.customIdentity = customIdentity
    }
    
    public init() {
        self.customIdentity = ""
    }

    open func onCreate(_ collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: IndexPath) {
        _cell = cell
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
        if self.isEnabled {
            _tap.onNext(())
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, value: UniqueCustomCollectionViewProvider) -> CGSize? {
        return self.itemSize?()
    }
    
    open func genteralValues() -> Observable<[UniqueCustomCollectionViewProvider]> {
        return self._isHidden.asObservable()
            .map { [weak self] isHidden in
                guard let `self` = self, !isHidden else { return [] }
                return [self]
        }
    }
    
}

extension UniqueCustomCollectionViewProvider: ReactiveCompatible { }

extension Reactive where Base: UniqueCustomCollectionViewProvider {

    public var isHidden: Binder<Bool> {
        return Binder(self.base) { provider, hidden in
            provider.isHidden = hidden
        }
    }

}
