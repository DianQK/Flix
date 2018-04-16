//
//  SelectedLocationProvider.swift
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

enum EventLocation: Equatable {

    static func ==(lhs: EventLocation, rhs: EventLocation) -> Bool {
        switch (lhs, rhs) {
        case (let .custom(l), let .custom(r)):
            return l == r
        case (let .placemark(l), let .placemark(r)):
            return l.addressDetail == r.addressDetail
        default:
            return false
        }
    }

    case custom(String)
    case placemark(CLPlacemark)

    var searchText: String {
        switch self {
        case let .custom(text):
            return text
        case let .placemark(placemark):
//            return [placemark.name, placemark.addressDetail].flatMap { $0 }.joined(separator: " ")
            return placemark.name ?? ""
        }
    }

}

private class SelectedLocationProviderTextField: UITextField {

    override var canBecomeFirstResponder: Bool {
        return false
    }

    override func becomeFirstResponder() -> Bool {
        return false
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }
        return (view == self) ? nil : view
    }

}

private class TextFieldDelegateProxy: NSObject, UITextFieldDelegate {

    let clearTap = PublishSubject<()>()

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        clearTap.onNext(())
        return true
    }

}

class SelectedLocationProvider: SingleUITableViewCellProvider {

    private let titleLabel = UILabel()
    private let addressLabel = UILabel()
    private let textField = SelectedLocationProviderTextField()
    private let textFieldDelegateProxy = TextFieldDelegateProxy()

    let disposeBag = DisposeBag()

    let location: BehaviorRelay<EventLocation?>

    init(viewController: UIViewController, selected: EventLocation?) {
        self.location = BehaviorRelay(value: selected)
        super.init()
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        addressLabel.font = UIFont.systemFont(ofSize: 11)
        textField.placeholder = "Location"
        textField.clearButtonMode = .unlessEditing

        self.contentView.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20).isActive = true
        textField.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20).isActive = true

        self.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: -20).isActive = true

        self.contentView.addSubview(addressLabel)
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor).isActive = true
        addressLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5).isActive = true
        addressLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor).isActive = true

        self.textField.delegate = self.textFieldDelegateProxy

        self.textFieldDelegateProxy.clearTap.asObservable().map { nil as EventLocation? }
            .bind(to: self.location)
            .disposed(by: disposeBag)

        location.asObservable()
            .subscribe(onNext: { [weak self] (location) in
                self?.titleLabel.text = nil
                self?.addressLabel.text = nil
                self?.textField.text = nil
                guard let location = location else { return }
                switch location {
                case let .custom(address):
                    self?.textField.text = address
                    self?.textField.textColor = UIColor.darkText
                case let .placemark(placemark):
                    self?.textField.text = "."
                    self?.textField.textColor = UIColor.clear
                    self?.titleLabel.text = placemark.name
                    self?.addressLabel.text = placemark.addressDetail
                }
            })
            .disposed(by: disposeBag)

        self.tap.asObservable()
            .flatMapLatest { [weak viewController, weak self] () -> Observable<EventLocation> in
                return SelectLocationViewController.rx.createWithParent(viewController) { (selectLocation) in
                    selectLocation.searchBar.text = self?.location.value?.searchText
                    }
                    .flatMap({ $0.didSelectLocation.asObservable() })
                    .take(1)
            }
            .bind(to: self.location)
            .disposed(by: disposeBag)

    }

}
