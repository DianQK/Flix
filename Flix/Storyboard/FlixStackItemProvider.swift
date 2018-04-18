//
//  FlixStackItemProvider.swift
//  Flix
//
//  Created by wc on 24/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

open class FlixStackItemProvider: UIControl, UniqueAnimatableTableViewProvider {

    public typealias Cell = UITableViewCell

    // Default is nil for cells in UITableViewStylePlain, and non-nil for UITableViewStyleGrouped. The 'backgroundView' will be added as a subview behind all other views.
    open var backgroundView: UIView? {
        didSet {
            _cell?.backgroundView = backgroundView
        }
    }

    // Default is nil for cells in UITableViewStylePlain, and non-nil for UITableViewStyleGrouped. The 'selectedBackgroundView' will be added as a subview directly above the backgroundView if not nil, or behind all other views. It is added as a subview only when the cell is selected. Calling -setSelected:animated: will cause the 'selectedBackgroundView' to animate in and out with an alpha fade.
    open var selectedBackgroundView: UIView? {
        didSet {
            _cell?.selectedBackgroundView = selectedBackgroundView
        }
    }

    open var multipleSelectionBackgroundView: UIView? {
        didSet {
            _cell?.multipleSelectionBackgroundView = multipleSelectionBackgroundView
        }
    }

    open var selectionStyle: UITableViewCellSelectionStyle = UITableViewCellSelectionStyle.default {
        didSet {
            _cell?.selectionStyle = selectionStyle
        }
    }

    // default is UITableViewCellAccessoryNone. use to set standard type
    open var accessoryType: UITableViewCellAccessoryType = UITableViewCellAccessoryType.none {
        didSet {
            _cell?.accessoryType = accessoryType
        }
    }

    // if set, use custom view. ignore accessoryType. tracks if enabled can calls accessory action
    open var accessoryView: UIView? {
        didSet {
            _cell?.accessoryView = accessoryView
        }
    }

    // default is UITableViewCellAccessoryNone. use to set standard type
    open var editingAccessoryType: UITableViewCellAccessoryType = .none {
        didSet {
            _cell?.editingAccessoryType = editingAccessoryType
        }
    }

    // if set, use custom view. ignore editingAccessoryType. tracks if enabled can calls accessory action
    open var editingAccessoryView: UIView? {
        didSet {
            _cell?.editingAccessoryView = editingAccessoryView
        }
    }

    // allows customization of the separator frame
    open var separatorInset: UIEdgeInsets? {
        didSet {
            if let separatorInset = separatorInset {
                _cell?.separatorInset = separatorInset
            }
        }
    }

    open var itemHeight: (() -> CGFloat?)?
    
    private let _isHidden = BehaviorRelay(value: false)
    
    open override var isHidden: Bool {
        get {
            return _isHidden.value
        }
        set {
            _isHidden.accept(newValue)
        }
    }
    
    private let disposeBag = DisposeBag()
    
    private weak var _cell: UITableViewCell?
    
    open func onCreate(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        cell.selectedBackgroundView = self.selectedBackgroundView
        cell.backgroundView = backgroundView
        cell.accessoryType = self.accessoryType
        cell.accessoryView = self.accessoryView
        cell.editingAccessoryType = self.editingAccessoryType
        cell.editingAccessoryView = self.editingAccessoryView
        cell.multipleSelectionBackgroundView = self.multipleSelectionBackgroundView
        cell.selectionStyle = self.selectionStyle
        if let separatorInset = self.separatorInset {
            cell.separatorInset = separatorInset
        }

        cell.contentView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
//        self.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
        self._cell = cell
    }

    open func itemSelected(_ tableView: UITableView, indexPath: IndexPath, value: FlixStackItemProvider) {
        if self.isEnabled {
            self.sendActions(for: UIControlEvents.touchUpInside)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, value: FlixStackItemProvider) -> CGFloat? {
        return self.itemHeight?()
    }
    
    open func createValues() -> Observable<[FlixStackItemProvider]> {
        return self._isHidden.asObservable()
            .map { [weak self] isHidden in
                guard let `self` = self, !isHidden else { return [] }
                return [self]
        }
    }

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let result = super.hitTest(point, with: event), (result !== self && result.isUserInteractionEnabled) else { return nil }
        return result
    }

}
