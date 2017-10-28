//
//  EventRadioProvider.swift
//  Example
//
//  Created by wc on 29/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

public protocol EventRadioType: StringIdentifiableType, Equatable {

    var name: String { get }

    static var allOptions: [[Self]] { get }

    static var title: String { get }

}

enum ShowAsOption: String, EventRadioType {

    case busy
    case free

    var name: String {
        switch self {
        case .busy:
            return "Busy"
        case .free:
            return "Free"
        }
    }

    static var allOptions: [[ShowAsOption]] {
        return [[.busy, .free]]
    }

    var identity: String {
        return self.rawValue
    }

    static func createProvider(viewController: UIViewController, selected: ShowAsOption) -> EventRadioProvider<ShowAsOption> {
        return EventRadioProvider<ShowAsOption>(viewController: viewController, selectedOption: selected)
    }

    static var title: String {
        return "Show As"
    }

}

class EventRadioProvider<T>: TitleDescProvider where T: EventRadioType {

    let selectedOption: Variable<T>

    let disposeBag = DisposeBag()

    required init(viewController: UIViewController, selectedOption: T, customTitle: String? = nil) {
        self.selectedOption = Variable(selectedOption)

        super.init()

        self.tap.asObservable()
            .withLatestFrom(self.selectedOption.asObservable())
            .flatMapLatest { [weak viewController] (option) -> Observable<T> in
                guard let viewController = viewController else { return Observable.empty() }
                let eventOptionsViewController = EventOptionsViewController(selectedOption: option)
                eventOptionsViewController.title = customTitle ?? T.title
                viewController.show(eventOptionsViewController, sender: nil)
                return eventOptionsViewController.optionSelected.asObservable()
            }
            .bind(to: self.selectedOption)
            .disposed(by: disposeBag)

        self.selectedOption.asObservable().map { $0.name }
            .bind(to: descLabel.rx.text)
            .disposed(by: disposeBag)

        titleLabel.text = customTitle ?? T.title
        descLabel.textColor = UIColor(named: "CommentText")
    }

}

enum AlertOption: EventRadioType {

    case none
    case atTimeOfEvent
    case minutesBefore(Int)
    case hourBefore(Int)
    case dayBefore(Int)
    case weekBefore(Int)

    static func ==(lhs: AlertOption, rhs: AlertOption) -> Bool {
        return lhs.name == rhs.name
    }

    func calculateDisplayName(before: Int, unit: String) -> String {
        return "\(before) \(unit)\(before == 1 ? "" : "s") before"
    }

    var name: String {
        switch self {
        case .none:
            return "None"
        case .atTimeOfEvent:
            return "At time of event"
        case let .minutesBefore(value):
            return calculateDisplayName(before: value, unit: "minute")
        case let .hourBefore(value):
            return calculateDisplayName(before: value, unit: "hour")
        case let .dayBefore(value):
            return calculateDisplayName(before: value, unit: "day")
        case let .weekBefore(value):
            return calculateDisplayName(before: value, unit: "week")
        }
    }

    static var allOptions: [[AlertOption]] {
        return [
            [.none],
            [
                .atTimeOfEvent,
                .minutesBefore(5), .minutesBefore(15), .minutesBefore(30),
                .hourBefore(1), .hourBefore(2),
                .dayBefore(1), .dayBefore(2),
                .weekBefore(1)
            ]
        ]
    }

    var identity: String {
        return self.name
    }

    static func createProvider(viewController: UIViewController, selected: AlertOption, customTitle: String) -> EventRadioProvider<AlertOption> {
        return EventRadioProvider<AlertOption>(viewController: viewController, selectedOption: selected, customTitle: customTitle)
    }

    static var title: String {
        return "Alert"
    }

}

struct CalendarOption: EventRadioType {

    static var allOptions: [[CalendarOption]] {
        return [[CalendarOption(name: "Home"), CalendarOption(name: "Work"), CalendarOption(name: "Personal")]]
    }

    static var title: String {
        return "Calendar"
    }

    var identity: String {
        return self.name
    }

    static func ==(lhs: CalendarOption, rhs: CalendarOption) -> Bool {
        return lhs.name == rhs.name
    }

    static func createProvider(viewController: UIViewController, selected: CalendarOption) -> EventRadioProvider<CalendarOption> {
        return EventRadioProvider<CalendarOption>(viewController: viewController, selectedOption: selected)
    }

    let name: String

}

class AlertGroupProvider: AnimatableTableViewGroupProvider {

    let firstAlertProvider: EventRadioProvider<AlertOption>
    let secondAlertProvider: EventRadioProvider<AlertOption>

    var providers: [_AnimatableTableViewMultiNodeProvider] {
        return [firstAlertProvider, secondAlertProvider]
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

    let disposeBag = DisposeBag()

    init(viewController: UIViewController) {
        self.firstAlertProvider = AlertOption.createProvider(viewController: viewController, selected: AlertOption.none, customTitle: "Alert")
        self.secondAlertProvider = AlertOption.createProvider(viewController: viewController, selected: AlertOption.none, customTitle: "Second Alert")

        self.firstAlertProvider.selectedOption.asObservable().filter { $0 == .none }
            .flatMap { [unowned self] _ in self.secondAlertProvider.selectedOption.asObservable().take(1).debug("secondAlertProvider").filter { $0 != .none } }
            .debug()
            .observeOn(MainScheduler.asyncInstance)
            .debug()
            .subscribe(onNext: { [weak self] (option) in
                guard let `self` = self else { return }
                self.firstAlertProvider.selectedOption.value = option
                self.secondAlertProvider.selectedOption.value = .none
            })
            .disposed(by: disposeBag)
    }

    func genteralAnimatableProviders() -> Observable<[_AnimatableTableViewMultiNodeProvider]> {
        return Observable.combineLatest(
        self.firstAlertProvider.selectedOption.asObservable().map { $0 == .none },
        self.secondAlertProvider.selectedOption.asObservable().map { $0 == .none }) { $0 && $1 }.distinctUntilChanged()
            .map { [weak self] first in
                guard let `self` = self else { return [] }
                return first ? [self.firstAlertProvider] : [self.firstAlertProvider, self.secondAlertProvider]
        }
    }
    
}
