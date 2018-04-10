//
//  UniqueCustomTableViewProvider.swift
//  Flix
//
//  Created by DianQK on 04/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

open class UniqueCustomTableViewProvider: UniqueAnimatableTableViewProvider {
    
    open let customIdentity: String
    open let contentView: UIView = NeverHitSelfView()
    open var selectedBackgroundView: UIView? {
        didSet {
            whenGetCell { (cell) in
                cell.selectedBackgroundView = self.selectedBackgroundView
            }
        }
    }
    open var backgroundView: UIView? {
        didSet {
            whenGetCell { (cell) in
                cell.backgroundView = self.backgroundView
            }
        }
    }
    
    open var accessoryType: UITableViewCellAccessoryType = .none {
        didSet {
            whenGetCell { (cell) in
                cell.accessoryType = self.accessoryType
            }
        }
    }

    open var accessoryView: UIView? {
        didSet {
            whenGetCell { (cell) in
                cell.accessoryView = self.accessoryView
            }
        }
    }

    open var editingAccessoryType: UITableViewCellAccessoryType = .none {
        didSet {
            whenGetCell { (cell) in
                cell.editingAccessoryType = self.editingAccessoryType
            }
        }
    }

    open var editingAccessoryView: UIView? {
        didSet {
            whenGetCell { (cell) in
                cell.editingAccessoryView = self.editingAccessoryView
            }
        }
    }

    open var separatorInset: UIEdgeInsets? {
        didSet {
            whenGetCell { (cell) in
                if let separatorInset = self.separatorInset {
                    cell.separatorInset = separatorInset
                }
            }
        }
    }

    open var selectionStyle: UITableViewCellSelectionStyle = .default {
        didSet {
            whenGetCell { (cell) in
                cell.selectionStyle = self.selectionStyle
            }
        }
    }

    open var isEnabled = true

    open var tap: ControlEvent<()> { return ControlEvent(events: _tap.asObservable()) }
    private let _tap = PublishSubject<()>()
    
    open var itemHeight: ((UITableView) -> CGFloat?)?

    open var didMoveToTableView: ((UITableView, UITableViewCell) -> ())?

    open var isHidden: Bool {
        get {
            return _isHidden.value
        }
        set {
            _isHidden.accept(newValue)
        }
    }
    private let _isHidden = BehaviorRelay(value: false)
    
    let disposeBag = DisposeBag()

    public weak var cell: UITableViewCell?

    private var _cellConfigQueues = [(UITableViewCell) -> ()]()
    
    public init(customIdentity: String) {
        self.customIdentity = customIdentity
    }
    
    public init() {
        self.customIdentity = ""
    }
    
    open func onCreate(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        self.cell = cell
        for config in _cellConfigQueues {
            config(cell)
        }
        _cellConfigQueues.removeAll()

        cell.contentView.addSubview(contentView)
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
        self.contentView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
        self.contentView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
        self.contentView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true

        if let superview = cell.superview as? UITableView {
            self.didMoveToTableView?(superview, cell)
        }
    }

    open func tap(_ tableView: UITableView, indexPath: IndexPath, value: UniqueCustomTableViewProvider) {
        if self.isEnabled {
            _tap.onNext(())
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, value: UniqueCustomTableViewProvider) -> CGFloat? {
        return self.itemHeight?(tableView)
    }
    
    open func genteralValues() -> Observable<[UniqueCustomTableViewProvider]> {
        return self._isHidden.asObservable()
            .map { [weak self] isHidden in
                guard let `self` = self, !isHidden else { return [] }
                return [self]
        }
    }

    public func whenGetCell(_ cellConfig: @escaping (UITableViewCell) -> ()) {
        if let cell = self.cell {
            cellConfig(cell)
        } else {
            self._cellConfigQueues.append(cellConfig)
        }
    }
    
}

extension UniqueCustomTableViewProvider: ReactiveCompatible { }

extension Reactive where Base: UniqueCustomTableViewProvider {

    public var isHidden: Binder<Bool> {
        return Binder(self.base) { provider, hidden in
            provider.isHidden = hidden
        }
    }

}
