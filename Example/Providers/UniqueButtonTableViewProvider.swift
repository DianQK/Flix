//
//  UniqueButtonTableViewProvider.swift
//  Example
//
//  Created by DianQK on 04/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

open class UniqueButtonTableViewProvider: UniqueCustomTableViewProvider {
    
    let textLabel = UILabel()
    let activityIndicatorView = UIActivityIndicatorView()
    
    public override init() {
        super.init()
        textLabel.textAlignment = .center
        
        backgroundView = UIView()
        selectedBackgroundView = UIView()
        contentView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        textLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        contentView.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        activityIndicatorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
}
