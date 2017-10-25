//
//  SelectedLoactionProvider.swift
//  Example
//
//  Created by wc on 27/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix
import CoreLocation

enum EventLocation {

    case custom(String)
    case placemark(CLPlacemark)

}

class SelectedLocationProvider: UniqueCustomTableViewProvider {

    private let titleLabel = UILabel()
    private let addressLabel = UILabel()
    private let textField = UITextField()

    let disposeBag = DisposeBag()

    let location = Variable(nil as EventLocation?)

    init(viewController: UIViewController) {
        super.init()
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        addressLabel.font = UIFont.systemFont(ofSize: 11)
        textField.placeholder = "Location"
        textField.isUserInteractionEnabled = false

        self.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20).isActive = true
        titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true

        self.contentView.addSubview(addressLabel)
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        addressLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5).isActive = true

        self.contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        textField.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true

        location.asObservable()
            .subscribe(onNext: { [weak self] (location) in
                self?.titleLabel.text = nil
                self?.addressLabel.text = nil
                self?.textField.text = nil
                guard let location = location else { return }
                switch location {
                case let .custom(address):
                    self?.textField.text = address
                case let .placemark(placemark):
                    self?.titleLabel.text = placemark.name
                    self?.addressLabel.text = placemark.addressDetail
                }
            })
            .disposed(by: disposeBag)
    }

}
