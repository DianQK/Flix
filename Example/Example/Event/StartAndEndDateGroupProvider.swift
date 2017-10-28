//
//  StartAndEndDateGroupProvider.swift
//  Example
//
//  Created by wc on 29/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

class StartAndEndDateGroupProvider: AnimatableTableViewGroupProvider {

    let startProvider = DateSelectGroupProvider()
    let endProvider = DateSelectGroupProvider()

    var providers: [_AnimatableTableViewMultiNodeProvider] {
        return [startProvider, endProvider].flatMap { $0.providers }
    }

    let disposeBag = DisposeBag()

    init() {
        startProvider.dateProvider.titleLabel.text = "Starts"
        endProvider.dateProvider.titleLabel.text = "Ends"

        startProvider.tapActiveChanged.asObservable().filter { $0 }.map { !$0 }.bind(to: endProvider.isActive).disposed(by: disposeBag)
        endProvider.tapActiveChanged.asObservable().filter { $0 } .map { !$0 }.bind(to: startProvider.isActive).disposed(by: disposeBag)

        let currentDate = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day, .hour], from: Date()))!

        self.startProvider.pickerProvider.datePicker.date = currentDate
        self.startProvider.pickerProvider.datePicker.sendActions(for: .valueChanged)
        self.endProvider.pickerProvider.datePicker.date = Calendar.current.date(byAdding: Calendar.Component.hour, value: 1, to: currentDate)!
        self.endProvider.pickerProvider.datePicker.sendActions(for: .valueChanged)

        Observable
            .combineLatest(
                startProvider.pickerProvider.datePicker.rx.date.asObservable(),
                endProvider.pickerProvider.datePicker.rx.date.asObservable()
            ) { (startDate, endDate) -> Bool in
                return endDate > startDate
            }
            .bind(to: endProvider.dateIsAvailable)
            .disposed(by: disposeBag)

    }

    // ugly
    func configureCell(_ tableView: UITableView, indexPath: IndexPath, value: String) -> UITableViewCell {
        return UITableViewCell()
    }

    func genteralValues() -> Observable<[String]> {
        return Observable.just([])
    }

    typealias Value = String
    // ugly

    func genteralAnimatableProviders() -> Observable<[_AnimatableTableViewMultiNodeProvider]> {
        return Observable.just([startProvider, endProvider])
    }

}
