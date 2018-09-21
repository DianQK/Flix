//
//  EventOptionProvider.swift
//  Example
//
//  Created by DianQK on 29/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

public protocol EventOptionType: StringIdentifiableType, Equatable {

    var name: String { get }

    static var allOptions: [[Self]] { get }

    static var title: String { get }

}

enum ShowAsOption: String, EventOptionType {

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

    static func createProvider(viewController: UIViewController, selected: ShowAsOption) -> EventOptionProvider<ShowAsOption> {
        return EventOptionProvider<ShowAsOption>(viewController: viewController, selectedOption: selected)
    }

    static var title: String {
        return "Show As"
    }

}

class EventOptionProvider<T>: TitleDescProvider where T: EventOptionType {

    let selectedOption: BehaviorRelay<T>

    required init(viewController: UIViewController, selectedOption: T, customTitle: String? = nil) {
        self.selectedOption = BehaviorRelay(value: selectedOption)

        super.init()

        self.event.selectedEvent.asObservable()
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

enum AlertOption: EventOptionType {

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

    static func createProvider(viewController: UIViewController, selected: AlertOption, customTitle: String) -> EventOptionProvider<AlertOption> {
        return EventOptionProvider<AlertOption>(viewController: viewController, selectedOption: selected, customTitle: customTitle)
    }

    static var title: String {
        return "Alert"
    }

}

struct CalendarOption: EventOptionType {

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

    static func createProvider(viewController: UIViewController, selected: CalendarOption) -> EventOptionProvider<CalendarOption> {
        return EventOptionProvider<CalendarOption>(viewController: viewController, selectedOption: selected)
    }

    let name: String

}

class AlertGroupProvider: AnimatableTableViewGroupProvider {

    let firstAlertProvider: EventOptionProvider<AlertOption>
    let secondAlertProvider: EventOptionProvider<AlertOption>

    var providers: [_AnimatableTableViewMultiNodeProvider] {
        return [firstAlertProvider, secondAlertProvider]
    }

    let disposeBag = DisposeBag()

    init(viewController: UIViewController, first: AlertOption?, second: AlertOption?) {
        self.firstAlertProvider = AlertOption.createProvider(viewController: viewController, selected: first ?? AlertOption.none, customTitle: "Alert")
        self.secondAlertProvider = AlertOption.createProvider(viewController: viewController, selected: second ?? AlertOption.none, customTitle: "Second Alert")

        self.firstAlertProvider.selectedOption.asObservable().filter { $0 == .none }
            .flatMap { [unowned self] _ in self.secondAlertProvider.selectedOption.asObservable().take(1).filter { $0 != .none } }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] (option) in
                guard let `self` = self else { return }
                self.firstAlertProvider.selectedOption.accept(option)
                self.secondAlertProvider.selectedOption.accept(.none)
            })
            .disposed(by: disposeBag)
    }

    func createAnimatableProviders() -> Observable<[_AnimatableTableViewMultiNodeProvider]> {
        return Observable.combineLatest(
        self.firstAlertProvider.selectedOption.asObservable().map { $0 == .none },
        self.secondAlertProvider.selectedOption.asObservable().map { $0 == .none }) { $0 && $1 }.distinctUntilChanged()
            .map { [weak self] first in
                guard let `self` = self else { return [] }
                return first ? [self.firstAlertProvider] : [self.firstAlertProvider, self.secondAlertProvider]
        }
    }
    
}
