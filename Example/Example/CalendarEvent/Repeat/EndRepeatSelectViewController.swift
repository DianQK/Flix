//
//  EndRepeatSelectViewController.swift
//  Example
//
//  Created by DianQK on 29/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

class EndRepeatSelectViewController: TableViewController {

    let endRepeatDate: BehaviorRelay<Date?>
    let minEndDate: Observable<Date>

    let neverProvider = TitleDescProvider()
    let onDateProvider = TitleDescProvider()
    let datePickerProvider: DatePickerProvider

    init(endRepeatDate: BehaviorRelay<Date?>, minEndDate: Observable<Date>) {
        self.endRepeatDate = endRepeatDate
        self.minEndDate = minEndDate
        self.datePickerProvider = DatePickerProvider(date: endRepeatDate.value)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "End Repeat"

        neverProvider.titleLabel.text = "Never"
        onDateProvider.titleLabel.text = "On Date"

        minEndDate
            .subscribe(onNext: { [weak self] (date) in
                self?.datePickerProvider.datePicker.minimumDate = date
            })
            .disposed(by: disposeBag)

        self.datePickerProvider.datePicker.rx.date.changed
            .bind(to: self.endRepeatDate)
            .disposed(by: disposeBag)

        let isNever = self.endRepeatDate.asObservable().map { $0 == nil }

        isNever.map { $0 ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none }
            .subscribe(onNext: { [weak self] (accessoryType) in
                self?.neverProvider.accessoryType = accessoryType
            })
            .disposed(by: disposeBag)

        isNever
            .subscribe(onNext: { [weak self] (isNever) in
                self?.onDateProvider.accessoryType = isNever ? UITableViewCell.AccessoryType.none : UITableViewCell.AccessoryType.checkmark
                self?.onDateProvider.titleLabel.textColor = isNever ? UIColor.darkText : UIColor(named: "Deep Carmine Pink")
            })
            .disposed(by: disposeBag)

        isNever.bind(to: self.datePickerProvider.rx.isHidden).disposed(by: disposeBag)

        self.neverProvider.event.selectedEvent.map { nil as Date? }.bind(to: self.endRepeatDate).disposed(by: disposeBag)

        self.onDateProvider.event.selectedEvent
            .withLatestFrom(self.datePickerProvider.datePicker.rx.date.asObservable())
            .bind(to: self.endRepeatDate)
            .disposed(by: disposeBag)

        self.tableView.flix.animatable.build([
            SpacingSectionProvider(providers: [neverProvider, onDateProvider, datePickerProvider], headerHeight: 18, footerHeight: 18)
            ])
    }

}
