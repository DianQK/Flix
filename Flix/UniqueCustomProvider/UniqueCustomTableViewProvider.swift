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

open class SingleTableViewCellProvider<Cell: UITableViewCell>: CustomProvider, ProviderHiddenable, UniqueAnimatableTableViewProvider, CustomIdentityType {

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

//    public let event: TableViewEvent<SingleTableViewCellProvider<Cell>> = TableViewEvent()

    let disposeBag = DisposeBag()
    
    public init(customIdentity: String) {
        self.customIdentity = customIdentity
    }
    
    public init() {
        self.customIdentity = ""
        let event = self.event
        debugPrint(self, event, Unmanaged.passUnretained(event).toOpaque())
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
            let event = self.event
            debugPrint(self, event, Unmanaged.passUnretained(event).toOpaque())
//            self.event.didMoveToTableViewSubject?.onNext((superview, cell))
//            self.event.hasMoveToTableViewSubject.onNext((superview, cell))
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

public protocol MoveToTableViewEventProvider {
    associatedtype Cell
}

private var _didMoveToTableViewSubjectKey: Void?
private var _hasMoveToTableViewSubjectKey: Void?

extension TableViewEventType where Provider: MoveToTableViewEventProvider {

    public typealias Cell = Provider.Cell

    var didMoveToTableViewSubject: PublishSubject<(UITableView, Cell)>? {
        get {
            return objc_getAssociatedObject(self, &_didMoveToTableViewSubjectKey) as? PublishSubject<(UITableView, Cell)>
        }
        set {
            objc_setAssociatedObject(self, &_didMoveToTableViewSubjectKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    public var didMoveToTableView: ControlEvent<(UITableView, Cell)> {
        let subject: PublishSubject<(UITableView, Cell)> = didMoveToTableViewSubject ?? {
            let subject = PublishSubject<(UITableView, Cell)>()
            didMoveToTableViewSubject = subject
            return subject
        }()
        return ControlEvent(events: subject)
    }

    var hasMoveToTableViewSubject: ReplaySubject<(UITableView, Cell)> {
        get {
            if let subject = objc_getAssociatedObject(self, &_hasMoveToTableViewSubjectKey) as? ReplaySubject<(UITableView, Cell)> {
                return subject
            } else {
                let subject = ReplaySubject<(UITableView, Cell)>.create(bufferSize: 1)
                objc_setAssociatedObject(self, &_hasMoveToTableViewSubjectKey, subject, .OBJC_ASSOCIATION_ASSIGN)
                return subject
            }
        }
    }

    public var hasMoveToTableView: ControlEvent<(UITableView, Cell)> {
        return ControlEvent(events: hasMoveToTableViewSubject)
    }

}
