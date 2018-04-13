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

class SwitchProvider: UniqueCustomTableViewProvider {

    let uiSwitch = UISwitch()
    let titleLabel = UILabel()

    override init() {
        super.init()
        self.contentView.addSubview(uiSwitch)
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        uiSwitch.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20).isActive = true
        uiSwitch.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0).isActive = true

        self.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0).isActive = true

        self.selectionStyle = .none
    }

}

class StartAndEndDateGroupProvider: AnimatableTableViewGroupProvider {

    let allDaySwitchProvider = SwitchProvider()
    let startProvider: DateSelectGroupProvider
    let endProvider: DateSelectGroupProvider

    var providers: [_AnimatableTableViewMultiNodeProvider] {
        return [allDaySwitchProvider, startProvider, endProvider]
    }

    var endDate: Observable<Date> {
        return self.endProvider.pickerProvider.datePicker.rx.date.asObservable()
    }

    let timeZone = BehaviorRelay(value: TimeZone.current)
    let disposeBag = DisposeBag()

    init(viewController: UIViewController, isAllDay: Bool?, start: Date?, end: Date?) {

        allDaySwitchProvider.titleLabel.text = "All-day"

        allDaySwitchProvider.uiSwitch.isOn = isAllDay ?? false
        let isAllDay = allDaySwitchProvider.uiSwitch.rx.isOn
        self.startProvider = DateSelectGroupProvider(timeZone: self.timeZone.asObservable(), isAllDay: isAllDay, date: start)
        self.endProvider = DateSelectGroupProvider(timeZone: self.timeZone.asObservable(), isAllDay: isAllDay, date: end)

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

        Observable.merge([self.startProvider.timeZoneProvider.tap.asObservable(), self.endProvider.timeZoneProvider.tap.asObservable()])
            .withLatestFrom(timeZone.asObservable())
            .flatMapLatest({ [weak viewController] (timeZone) -> Observable<TimeZone> in
                guard let `viewController` = viewController else { return Observable.empty() }
                let selectTimeZoneViewController = SelectTimeZoneViewController(currentTimeZone: timeZone)
                viewController.show(selectTimeZoneViewController, sender: nil)
                return selectTimeZoneViewController.timeZoneSelected.asObservable()
            })
            .bind(to: self.timeZone)
            .disposed(by: disposeBag)

    }

    func createAnimatableProviders() -> Observable<[_AnimatableTableViewMultiNodeProvider]> {
        return Observable.just([allDaySwitchProvider, startProvider, endProvider])
    }

}
