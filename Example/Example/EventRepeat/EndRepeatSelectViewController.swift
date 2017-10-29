//
//  EndRepeatSelectViewController.swift
//  Example
//
//  Created by wc on 29/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

class EndRepeatSelectViewController: TableViewController {

    let endRepeatDate: Variable<Date?>
    let minEndDate: Observable<Date>

    let neverProvider = TitleDescProvider()
    let onDateProvider = TitleDescProvider()
    let datePickerProvider = DatePickerProvider()

    init(endRepeatDate: Variable<Date?>, minEndDate: Observable<Date>) {
        self.endRepeatDate = endRepeatDate
        self.minEndDate = minEndDate
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

        self.view.tintColor = UIColor(named: "Deep Carmine Pink")

        minEndDate
            .subscribe(onNext: { [weak self] (date) in
                self?.datePickerProvider.datePicker.minimumDate = date
            })
            .disposed(by: disposeBag)

        if let endRepeatDate = endRepeatDate.value {
            self.datePickerProvider.datePicker.date = endRepeatDate
        }

        self.datePickerProvider.datePicker.rx.date.changed
            .bind(to: self.endRepeatDate)
            .disposed(by: disposeBag)

        let isNever = self.endRepeatDate.asObservable().map { $0 == nil }

        isNever.map { $0 ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none }
            .subscribe(onNext: { [weak self] (accessoryType) in
                self?.neverProvider.accessoryType = accessoryType
            })
            .disposed(by: disposeBag)

        isNever
            .subscribe(onNext: { [weak self] (isNever) in
                self?.onDateProvider.accessoryType = isNever ? UITableViewCellAccessoryType.none : UITableViewCellAccessoryType.checkmark
                self?.onDateProvider.titleLabel.textColor = isNever ? UIColor.darkText : UIColor(named: "Deep Carmine Pink")
            })
            .disposed(by: disposeBag)

        isNever.bind(to: self.datePickerProvider.isHidden).disposed(by: disposeBag)

        self.neverProvider.tap.map { nil as Date? }.bind(to: self.endRepeatDate).disposed(by: disposeBag)

        self.onDateProvider.tap
            .withLatestFrom(self.datePickerProvider.datePicker.rx.date.asObservable())
            .bind(to: self.endRepeatDate)
            .disposed(by: disposeBag)

        self.tableView.flix.animatable.build([
            SpacingSectionProvider(providers: [neverProvider, onDateProvider, datePickerProvider], headerHeight: 18, footerHeight: 18)
            ])
    }

}
