//
//  DateSelectProvider.swift
//  Example
//
//  Created by wc on 28/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

class SelectedDateDisplayProvider: SingleUITableViewCellProvider {

    let titleLabel = UILabel()
    let dateLabel = UILabel()

    override init() {
        super.init()

        self.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true

        self.contentView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
    }

}

class DatePickerProvider: SingleUITableViewCellProvider {

    let datePicker = UIDatePicker()

    init(date: Date?) {
        super.init()

        if let date = date {
            self.datePicker.date = date
        }

        self.itemHeight = { _ in return 216 }

        self.contentView.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        datePicker.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true

        self.selectionStyle = .none

    }

}

class TitleDescProvider: SingleUITableViewCellProvider {

    let titleLabel = UILabel()
    let descLabel = UILabel()

    let disposeBag = DisposeBag()

    override init() {
        super.init()

        self.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true

        self.accessoryType = .disclosureIndicator

        self.contentView.addSubview(descLabel)
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -5).isActive = true
        descLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true
    }
}

extension Reactive where Base: UILabel {

    public var textColor: Binder<UIColor> {
        return Binder(self.base, binding: { (label, textColor) in
            label.textColor = textColor
        })
    }

}

class DateSelectGroupProvider: AnimatableTableViewGroupProvider {

    let dateProvider = SelectedDateDisplayProvider()
    let pickerProvider: DatePickerProvider
    let timeZoneProvider = TitleDescProvider()

    var providers: [_AnimatableTableViewMultiNodeProvider] {
        return [dateProvider, pickerProvider, timeZoneProvider]
    }

    let isActive = BehaviorRelay(value: false)
    let disposeBag = DisposeBag()
    let tapActiveChanged = PublishSubject<Bool>()

    let dateIsAvailable = BehaviorRelay(value: true)

    let isAllDay: ControlProperty<Bool>

    init(timeZone: Observable<TimeZone>, isAllDay: ControlProperty<Bool>, date: Date?) {
        self.pickerProvider = DatePickerProvider(date: date)

        let timeZone = timeZone.share(replay: 1, scope: .forever)
        self.isAllDay = isAllDay

        self.dateProvider.tap.asObservable()
            .withLatestFrom(self.isActive.asObservable()).map { !$0 }
            .do(onNext: { [weak self] (isActive) in
                self?.tapActiveChanged.onNext(isActive)
            })
            .bind(to: self.isActive)
            .disposed(by: disposeBag)

        let dateformatter = Observable.combineLatest(isAllDay.asObservable(), timeZone).map { (isAllDay, timeZone) -> DateFormatter in
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = isAllDay ? "EEE, MMM d, y" : "MM/dd/yy  h:mm:ss a z"
            dateformatter.timeZone = timeZone
            return dateformatter
        }

        let date: Observable<String> = Observable.combineLatest(pickerProvider.datePicker.rx.date, dateformatter) { $1.string(from: $0) }

        Observable.combineLatest(
            date,
            dateIsAvailable.asObservable(),
            isActive.asObservable().distinctUntilChanged().map { $0 ? UIColor(named: "Deep Carmine Pink")! : UIColor.darkText }
            )
            .map { (date, isAvailable, textColor) -> NSAttributedString in
                return NSAttributedString(
                    string: date,
                    attributes: [
                        NSAttributedStringKey.strikethroughStyle: (isAvailable ? NSUnderlineStyle.styleNone : NSUnderlineStyle.styleSingle).rawValue,
                        NSAttributedStringKey.foregroundColor: textColor
                    ]
                )
            }
            .bind(to: dateProvider.dateLabel.rx.attributedText)
            .disposed(by: disposeBag)

        timeZoneProvider.titleLabel.text = "Time Zone"

        timeZone.map { $0.identifier }
            .bind(to: self.timeZoneProvider.descLabel.rx.text)
            .disposed(by: disposeBag)

        isAllDay.asObservable()
            .subscribe(onNext: { [weak self] (isAllDay) in
                guard let `self` = self else { return }
                self.pickerProvider.datePicker.datePickerMode = isAllDay ? .date : .dateAndTime
            })
            .disposed(by: disposeBag)
    }

    func createAnimatableProviders() -> Observable<[_AnimatableTableViewMultiNodeProvider]> {
        return Observable
            .combineLatest(self.isActive.asObservable(), self.isAllDay.asObservable()) { [weak self] (isActive, isAllDay) -> [_AnimatableTableViewMultiNodeProvider] in
                guard let `self` = self else { return [] }
                switch (isActive, isAllDay) {
                case (true, true):
                    return [self.dateProvider, self.pickerProvider]
                case (true, false):
                    return [self.dateProvider, self.pickerProvider, self.timeZoneProvider]
                case (false, _):
                    return [self.dateProvider]
                }
            }
            .distinctUntilChanged { (lhs, rhs) -> Bool in
                return lhs.count == rhs.count
            }
    }

}
