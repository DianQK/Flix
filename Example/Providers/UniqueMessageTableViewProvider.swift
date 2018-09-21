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

struct ValidationColors {
    static let okColor = UIColor(red: 138.0 / 255.0, green: 221.0 / 255.0, blue: 109.0 / 255.0, alpha: 1.0)
    static let errorColor = UIColor.red
}

extension ValidationResult {
    var textColor: UIColor {
        switch self {
        case .ok:
            return ValidationColors.okColor
        case .empty:
            return UIColor.black
        case .validating:
            return UIColor.black
        case .failed:
            return ValidationColors.errorColor
        }
    }
}

extension ValidationResult: CustomStringConvertible {
    var description: String {
        switch self {
        case let .ok(message):
            return message
        case .empty:
            return ""
        case .validating:
            return "validating ..."
        case let .failed(message):
            return message
        }
    }
}

open class ValidationTableViewProvider<ValueProvider: _AnimatableTableViewMultiNodeProvider>: AnimatableTableViewGroupProvider {

    public var providers: [_AnimatableTableViewMultiNodeProvider] {
        return [self.valueProvider, self.uniqueMessageTableViewProvider]
    }

    public func createAnimatableProviders() -> Observable<[_AnimatableTableViewMultiNodeProvider]> {
        return Observable.just([self.valueProvider, self.uniqueMessageTableViewProvider])
    }

    public let valueProvider: ValueProvider
    public let uniqueMessageTableViewProvider = UniqueMessageTableViewProvider()

    public init(valueProvider: ValueProvider) {
        self.valueProvider = valueProvider
    }

    var validationResult: Binder<ValidationResult> {
        return self.uniqueMessageTableViewProvider.validationResult
    }

}

open class UniqueMessageTableViewProvider: SingleUITableViewCellProvider {

    public let messageLabel = UILabel()
    
    let disposeBag = DisposeBag()
    
    public override init() {
        super.init()
        self.messageLabel.font = UIFont.systemFont(ofSize: 12)
        self.messageLabel.textColor = UIColor.white

        self.selectionStyle = .none
        self.contentView.addSubview(messageLabel)
        self.messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.messageLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.messageLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        self.messageLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15).isActive = true
        self.messageLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true

        self.backgroundView = UIView()

        itemHeight = { _ in 30 }
    }

    var validationResult: Binder<ValidationResult> {
        return Binder(self) { provider, result in
            provider.backgroundView?.backgroundColor = result.textColor
            provider.messageLabel.text = result.description
            provider.isHidden = result.description.isEmpty
        }
    }
    
}
