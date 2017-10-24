//
//  UniqueCustomTableViewSectionProvider.swift
//  Flix
//
//  Created by DianQK on 04/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift

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
    
    public let isHidden = Variable(false)
    
    open var sectionHeight: (() -> CGFloat)?
    
    open let contentView = UIView()
    open var backgroundView: UIView?
    
    public init(customIdentity: String, tableElementKindSection: UITableElementKindSection) {
        self.customIdentity = customIdentity
        self.tableElementKindSection = tableElementKindSection
    }
    
    public init(tableElementKindSection: UITableElementKindSection) {
        self.customIdentity = ""
        self.tableElementKindSection = tableElementKindSection
    }

    open func tableView(_ tableView: UITableView, heightInSection section: Int, value: UniqueCustomTableViewSectionProvider) -> CGFloat? {
        return self.sectionHeight?()
    }

    open func configureSection(_ tableView: UITableView, view: UITableViewHeaderFooterView, viewInSection section: Int, value: UniqueCustomTableViewSectionProvider) {
        if !view.hasConfigured {
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

    open func genteralSection() -> Observable<UniqueCustomTableViewSectionProvider?> {
        return self.isHidden.asObservable()
            .map { [weak self] isHidden in
                return isHidden ? nil : self
        }
    }
    
}
