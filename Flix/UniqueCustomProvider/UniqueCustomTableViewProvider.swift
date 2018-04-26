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

public typealias SingleUITableViewCellProvider = SingleTableViewCellProvider<UITableViewCell>
@available(*, deprecated, renamed: "SingleUITableViewCellProvider")
public typealias UniqueCustomTableViewProvider = SingleUITableViewCellProvider

open class SingleTableViewCellProvider<Cell: UITableViewCell>: CustomProvider, UniqueAnimatableTableViewProvider, CustomIdentityType {
    
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
    
    open var accessoryType: UITableViewCellAccessoryType = .none {
        didSet {
            whenGetCell { [weak self] (cell) in
                guard let `self` = self else { return }
                cell.accessoryType = self.accessoryType
            }
        }
    }

    open var accessoryView: UIView? {
        didSet {
            whenGetCell { [weak self] (cell) in
                guard let `self` = self else { return }
                cell.accessoryView = self.accessoryView
            }
        }
    }

    open var editingAccessoryType: UITableViewCellAccessoryType = .none {
        didSet {
            whenGetCell { [weak self] (cell) in
                guard let `self` = self else { return }
                cell.editingAccessoryType = self.editingAccessoryType
            }
        }
    }

    open var editingAccessoryView: UIView? {
        didSet {
            whenGetCell { [weak self] (cell) in
                guard let `self` = self else { return }
                cell.editingAccessoryView = self.editingAccessoryView
            }
        }
    }

    open var separatorInset: UIEdgeInsets? {
        didSet {
            whenGetCell { [weak self] (cell) in
                guard let `self` = self else { return }
                if let separatorInset = self.separatorInset {
                    cell.separatorInset = separatorInset
                }
            }
        }
    }

    open var selectionStyle: UITableViewCellSelectionStyle = .default {
        didSet {
            whenGetCell { [weak self] (cell) in
                guard let `self` = self else { return }
                cell.selectionStyle = self.selectionStyle
            }
        }
    }

    open var isEnabled = true

    @available(*, deprecated, renamed: "event.selectedEvent")
    open var tap: ControlEvent<()> { return self.event.selectedEvent }
    
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
    
    public init(customIdentity: String) {
        self.customIdentity = customIdentity
    }
    
    public init() {
        self.customIdentity = ""
    }
    
    open func onCreate(_ tableView: UITableView, cell: Cell, indexPath: IndexPath) {
        self.onGetCell(cell)
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

    open func itemSelected(_ tableView: UITableView, indexPath: IndexPath, value: SingleTableViewCellProvider) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, value: SingleTableViewCellProvider) -> CGFloat? {
        return self.itemHeight?(tableView)
    }
    
    open func createValues() -> Observable<[SingleTableViewCellProvider]> {
        return self._isHidden.asObservable()
            .map { [weak self] isHidden in
                guard let `self` = self, !isHidden else { return [] }
                return [self]
        }
    }

    open func register(_ tableView: UITableView) {
        tableView.register(Cell.self, forCellReuseIdentifier: self._flix_identity)
    }

}

extension SingleTableViewCellProvider: ReactiveCompatible { }

extension Reactive where Base: SingleTableViewCellProvider<UITableViewCell> { // TODO: extension for SingleTableViewCellProvider

    public var isHidden: Binder<Bool> {
        return Binder(self.base) { provider, hidden in
            provider.isHidden = hidden
        }
    }

}
