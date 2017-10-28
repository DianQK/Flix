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

class DateSelectCell: UITableViewCell {

    let titleLabel = UILabel()
    let dateLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.text = "Starts"

        self.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true

        self.contentView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor).isActive = true

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class DatePickerCell: UITableViewCell {

//    let datePicker = UIDatePicker()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

//        self.contentView.addSubview(datePicker)
//        datePicker.translatesAutoresizingMaskIntoConstraints = false
//        datePicker.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
//        datePicker.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true

        self.selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class TimeZoneCell: UITableViewCell {

    let titleLabel = UILabel()
    let descLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.text = "Time Zone"

        self.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true

        self.accessoryType = .disclosureIndicator
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

enum DateSelectType: String, StringIdentifiableType {

    case date
    case picker
    case timeZone

    var identity: String {
        return self.rawValue
    }

}

class DateSelectProvider: AnimatableTableViewMultiNodeProvider { //TODO: Use Group Provider

    let isActive = Variable(false)

    let datePicker = UIDatePicker()

    let disposeBag = DisposeBag()

    func configureCell(_ tableView: UITableView, indexPath: IndexPath, value: DateSelectType) -> UITableViewCell {
        switch value {
        case .date:
            let cell = tableView.dequeueReusableCell(withIdentifier: self._flix_identity + DateSelectType.date.rawValue, for: indexPath) as! DateSelectCell
            if !cell.hasConfigured {
                cell.hasConfigured = true
                datePicker.rx.date.map { $0.description }
                    .bind(to: cell.dateLabel.rx.text)
                    .disposed(by: disposeBag)
                isActive.asObservable()
                    .map { $0 ? UIColor(named: "Deep Carmine Pink")! : UIColor.darkText }
                    .subscribe(onNext: { [weak cell] (color) in
                        cell?.dateLabel.textColor = color
                    })
                    .disposed(by: disposeBag)
            }
            return cell
        case .picker:
            let cell = tableView.dequeueReusableCell(withIdentifier: self._flix_identity + DateSelectType.picker.rawValue, for: indexPath) as! DatePickerCell
            if !cell.hasConfigured {
                cell.hasConfigured = true
                cell.contentView.addSubview(datePicker)
                datePicker.translatesAutoresizingMaskIntoConstraints = false
                datePicker.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
                datePicker.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor).isActive = true
            }
            return cell
        case .timeZone:
            let cell = tableView.dequeueReusableCell(withIdentifier: self._flix_identity + DateSelectType.timeZone.rawValue, for: indexPath) as! TimeZoneCell
            return cell
        }
    }

    func genteralValues() -> Observable<[DateSelectType]> {
        return self.isActive.asObservable().distinctUntilChanged()
            .map { $0 ? [DateSelectType.date, DateSelectType.picker, DateSelectType.timeZone] : [DateSelectType.date] }
    }

    func register(_ tableView: UITableView) {
        tableView.register(DateSelectCell.self, forCellReuseIdentifier: self._flix_identity + DateSelectType.date.rawValue)
        tableView.register(DatePickerCell.self, forCellReuseIdentifier: self._flix_identity + DateSelectType.picker.rawValue)
        tableView.register(TimeZoneCell.self, forCellReuseIdentifier: self._flix_identity + DateSelectType.timeZone.rawValue)
    }

    func tap(_ tableView: UITableView, indexPath: IndexPath, value: DateSelectType) {
        if (value == .date) {
            self.isActive.value = !self.isActive.value
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, value: DateSelectType) -> CGFloat? {
        switch value {
        case .date, .timeZone:
            return 44
        case .picker:
            return 216
        }
    }

    typealias Value = DateSelectType

}
