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
    open var selectedBackgroundView: UIView?
    open var backgroundView: UIView?
    
    open var accessoryType: UITableViewCellAccessoryType = .none {
        didSet {
            _cell?.accessoryType = accessoryType
        }
    }

    open var accessoryView: UIView? {
        didSet {
            _cell?.accessoryView = accessoryView
        }
    }

    open var editingAccessoryType: UITableViewCellAccessoryType = .none {
        didSet {
            _cell?.editingAccessoryType = editingAccessoryType
        }
    }

    open var editingAccessoryView: UIView? {
        didSet {
            _cell?.editingAccessoryView = editingAccessoryView
        }
    }

    open var separatorInset: UIEdgeInsets? {
        didSet {
            if let separatorInset = separatorInset {
                _cell?.separatorInset = separatorInset
            }
        }
    }
    
    public let selectionStyle = BehaviorRelay(value: UITableViewCellSelectionStyle.default) // default is UITableViewCellSelectionStyleDefault.
    open var isEnabled = true

    open var tap: ControlEvent<()> { return ControlEvent(events: _tap.asObservable()) }
    private let _tap = PublishSubject<()>()
    
    open var itemHeight: ((UITableView) -> CGFloat?)?
    
    open var isHidden: Bool {
        get {
            return _isHidden.value
        }
        set {
            _isHidden.accept(newValue)
        }
    }
    private let _isHidden = BehaviorRelay(value: false)
    
    private let disposeBag = DisposeBag()

    private weak var _cell: UITableViewCell?
    
    public init(customIdentity: String) {
        self.customIdentity = customIdentity
    }
    
    public init() {
        self.customIdentity = ""
    }
    
    open func onCreate(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        _cell = cell
        cell.selectedBackgroundView = self.selectedBackgroundView
        cell.backgroundView = backgroundView
        cell.accessoryType = self.accessoryType
        cell.accessoryView = self.accessoryView
        cell.editingAccessoryType = self.editingAccessoryType
        cell.editingAccessoryView = self.editingAccessoryView
        if let separatorInset = self.separatorInset {
            cell.separatorInset = separatorInset
        }
        
        self.selectionStyle.asObservable()
            .subscribe(onNext: { [weak cell] (style) in
                cell?.selectionStyle = style
            })
            .disposed(by: disposeBag)
        
        cell.contentView.addSubview(contentView)
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
        self.contentView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
        self.contentView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
        self.contentView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
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
    
}

extension UniqueCustomTableViewProvider: ReactiveCompatible { }

extension Reactive where Base: UniqueCustomTableViewProvider {

    public var isHidden: Binder<Bool> {
        return Binder(self.base) { provider, hidden in
            provider.isHidden = hidden
        }
    }

}
