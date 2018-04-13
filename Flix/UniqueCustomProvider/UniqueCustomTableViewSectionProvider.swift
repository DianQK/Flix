//
//  UniqueCustomTableViewSectionProvider.swift
//  Flix
//
//  Created by DianQK on 04/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

open class UniqueCustomTableViewSectionProvider: AnimatablePartionSectionTableViewProvider, StringIdentifiableType, Equatable {
    
    public var identity: String {
        return self._flix_identity
    }

    public static func ==(lhs: UniqueCustomTableViewSectionProvider, rhs: UniqueCustomTableViewSectionProvider) -> Bool {
        return true
    }
    
    public typealias Cell = UITableViewHeaderFooterView
    public typealias Value = UniqueCustomTableViewSectionProvider

    open let customIdentity: String
    open let tableElementKindSection: UITableElementKindSection

    open var isHidden: Bool {
        get {
            return _isHidden.value
        }
        set {
            _isHidden.accept(newValue)
        }
    }
    private let _isHidden = BehaviorRelay(value: false)
    
    open var sectionHeight: ((UITableView) -> CGFloat)?
    
    open let contentView: UIView = NeverHitSelfView()
    open var backgroundView: UIView? {
        didSet {
            _view?.backgroundView = backgroundView
        }
    }

    private weak var _view: UITableViewHeaderFooterView?
    
    public init(customIdentity: String, tableElementKindSection: UITableElementKindSection) {
        self.customIdentity = customIdentity
        self.tableElementKindSection = tableElementKindSection
    }
    
    public init(tableElementKindSection: UITableElementKindSection) {
        self.customIdentity = ""
        self.tableElementKindSection = tableElementKindSection
    }

    open func tableView(_ tableView: UITableView, heightInSection section: Int, value: UniqueCustomTableViewSectionProvider) -> CGFloat? {
        return self.sectionHeight?(tableView)
    }

    open func configureSection(_ tableView: UITableView, view: UITableViewHeaderFooterView, viewInSection section: Int, value: UniqueCustomTableViewSectionProvider) {
        if !view.hasConfigured {
            _view = view
            view.hasConfigured = true
            view.backgroundView = self.backgroundView
            view.contentView.addSubview(contentView)
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.topAnchor.constraint(equalTo: view.contentView.topAnchor).isActive = true
            contentView.leadingAnchor.constraint(equalTo: view.contentView.leadingAnchor).isActive = true
            contentView.trailingAnchor.constraint(equalTo: view.contentView.trailingAnchor).isActive = true
            contentView.bottomAnchor.constraint(equalTo: view.contentView.bottomAnchor).isActive = true
        }
    }

    open func createSection() -> Observable<UniqueCustomTableViewSectionProvider?> {
        return self._isHidden.asObservable()
            .map { [weak self] isHidden in
                return isHidden ? nil : self
        }
    }
    
}

extension Reactive where Base: UniqueCustomTableViewSectionProvider {

    public var isHidden: Binder<Bool> {
        return Binder(self.base) { provider, hidden in
            provider.isHidden = hidden
        }
    }

}
