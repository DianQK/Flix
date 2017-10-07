//
//  UniqueCustomTableViewProvider.swift
//  Flix
//
//  Created by DianQK on 04/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift

open class UniqueCustomTableViewProvider: UniqueAnimatableTableViewProvider {
    
    open let identity: String
    open let contentView = UIView()
    open var selectedBackgroundView: UIView?
    open var backgroundView: UIView?
    
    open var accessoryType: UITableViewCellAccessoryType = .none // default is UITableViewCellAccessoryNone. use to set standard type
    open var accessoryView: UIView? // if set, use custom view. ignore accessoryType. tracks if enabled can calls accessory action
    open var editingAccessoryType: UITableViewCellAccessoryType = .none // default is UITableViewCellAccessoryNone. use to set standard type
    open var editingAccessoryView: UIView? // if set, use custom view. ignore editingAccessoryType. tracks if enabled can calls accessory action
    open var separatorInset: UIEdgeInsets? // allows customization of the separator frame
    
    public let selectionStyle = Variable(UITableViewCellSelectionStyle.default) // default is UITableViewCellSelectionStyleDefault.
    open var isEnabled = true

    open var tap: Observable<()> { return _tap.asObservable() }
    private let _tap = PublishSubject<()>()
    
    open var itemHeight: (() -> CGFloat?)?
    
    public let isHidden = Variable(false)
    
    private let disposeBag = DisposeBag()
    
    public init(identity: String) {
        self.identity = identity
    }
    
    open func onCreate(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
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

    open func tap(_ tableView: UITableView, indexPath: IndexPath, node: UniqueCustomTableViewProvider) {
        if self.isEnabled {
            _tap.onNext(())
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, node: UniqueCustomTableViewProvider) -> CGFloat? {
        return self.itemHeight?()
    }
    
    open func genteralNodes() -> Observable<[UniqueCustomTableViewProvider]> {
        return self.isHidden.asObservable()
            .map { [weak self] isHidden in
                guard let `self` = self, !isHidden else { return [] }
                return [self]
        }
    }
    
}
