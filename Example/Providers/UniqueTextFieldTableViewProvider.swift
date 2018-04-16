//
//  UniqueTextFieldTableViewProvider.swift
//  Example
//
//  Created by DianQK on 04/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

open class UniqueTextFieldTableViewProvider: SingleUITableViewCellProvider {

    open let textField = UITextField()

    public override init() {
        super.init()
        self.selectionStyle = .none
        self.contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        textField.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15).isActive = true
        textField.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
    }
    
}
