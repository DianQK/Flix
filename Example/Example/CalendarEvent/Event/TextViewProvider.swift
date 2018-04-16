//
//  TextViewProvider.swift
//  Example
//
//  Created by wc on 29/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import Flix

class TextViewProvider: UITextView, UniqueAnimatableTableViewProvider {

    typealias Cell = UITableViewCell

    let disposeBag = DisposeBag()
    private let placeholderTextField = UITextField()

    var placeholder: String? {
        get {
            return placeholderTextField.placeholder
        }
        set {
            placeholderTextField.placeholder = newValue
        }
    }

    func onCreate(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        cell.contentView.addSubview(self)
        self.font = UIFont.systemFont(ofSize: 17)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isScrollEnabled = false
        self.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 0).isActive = true
        self.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 0).isActive = true
        self.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: 0).isActive = true
        self.textContainerInset = UIEdgeInsets(top: 12, left: 20, bottom: 0, right: 20)
        self.contentInset = UIEdgeInsets.zero
        self.contentInsetAdjustmentBehavior = .never

        cell.contentView.addSubview(placeholderTextField)
        placeholderTextField.translatesAutoresizingMaskIntoConstraints = false
        placeholderTextField.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 12).isActive = true
        placeholderTextField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20).isActive = true
        placeholderTextField.isUserInteractionEnabled = false

        self.rx.text.orEmpty.changed
            .distinctUntilChanged()
            .subscribe(onNext: { [weak tableView, weak self] (text) in
                self?.placeholderTextField.isHidden = !text.isEmpty
                tableView?.performBatchUpdates(nil, completion: nil)
            })
            .disposed(by: disposeBag)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, value: TextViewProvider) -> CGFloat? {
        let height = NSAttributedString(string: value.text, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17)]).boundingRect(with: CGSize(width: tableView.bounds.width - 40, height: CGFloat.greatestFiniteMagnitude), options: [NSStringDrawingOptions.usesFontLeading, .usesLineFragmentOrigin], context: nil).height + 12
        return max(120, height)
    }

}
