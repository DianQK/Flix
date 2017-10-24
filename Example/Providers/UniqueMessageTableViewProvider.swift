//
//  UniqueMessageTableViewProvider.swift
//  Example
//
//  Created by DianQK on 04/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

open class UniqueMessageTableViewProvider: UniqueAnimatableTableViewProvider {

    open let messageLabel = UILabel()
    open let contentView = UIView()
    open let backgroundView = UIView()
    
    open let isHidden = Variable(false)
    
    let disposeBag = DisposeBag()
    
    public init() {
        self.messageLabel.font = UIFont.systemFont(ofSize: 12)
        self.messageLabel.textColor = UIColor.white
    }
    
    open func onCreate(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        cell.selectionStyle = .none
        cell.backgroundView = self.backgroundView
        cell.contentView.addSubview(messageLabel)
        self.messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.messageLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
        self.messageLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 15).isActive = true
        self.messageLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -15).isActive = true
        self.messageLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, value: UniqueMessageTableViewProvider) -> CGFloat? {
        return 30
    }
    
    open func genteralValues() -> Observable<[UniqueMessageTableViewProvider]> {
        return self.isHidden.asObservable()
            .distinctUntilChanged()
            .map { [weak self] isHidden in
                guard let `self` = self, !isHidden else { return [] }
                return [self]
        }
    }
    
}
