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

    open let valueProvider: ValueProvider
    open let uniqueMessageTableViewProvider = UniqueMessageTableViewProvider()

    public init(valueProvider: ValueProvider) {
        self.valueProvider = valueProvider
    }

    var validationResult: Binder<ValidationResult> {
        return self.uniqueMessageTableViewProvider.validationResult
    }

}

open class UniqueMessageTableViewProvider: UniqueAnimatableTableViewProvider {

    open let messageLabel = UILabel()
    open let contentView = UIView()
    open let backgroundView = UIView()
    
    open let isHidden = BehaviorRelay(value: false)
    
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
    
    open func createValues() -> Observable<[UniqueMessageTableViewProvider]> {
        return self.isHidden.asObservable()
            .distinctUntilChanged()
            .map { [weak self] isHidden in
                guard let `self` = self, !isHidden else { return [] }
                return [self]
        }
    }

    var validationResult: Binder<ValidationResult> {
        return Binder(self) { provider, result in
            provider.backgroundView.backgroundColor = result.textColor
            provider.messageLabel.text = result.description
            provider.isHidden.accept(result.description.isEmpty)
        }
    }
    
}
