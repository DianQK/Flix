//
//  TextFieldProvider.swift
//  Example
//
//  Created by wc on 27/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

class TextFieldProvider: UITextField, UniqueAnimatableTableViewProvider {

    func onCreate(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        cell.contentView.addSubview(self)
        self.clearButtonMode = .whileEditing
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20).isActive = true
        self.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20).isActive = true
    }

}
