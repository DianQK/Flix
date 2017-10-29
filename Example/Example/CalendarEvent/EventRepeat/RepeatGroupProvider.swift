//
//  RepeatGroupProvider.swift
//  Example
//
//  Created by wc on 29/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

enum RepeatOption: String, EventRadioType {

    static var allOptions: [[RepeatOption]] {
        return [[.never, .everyDay, .everyWeek, .every2Weeks, .everyMonth, .everyYear]]
    }

    static var title: String {
        return "Repeat"
    }

    case never = "Never"
    case everyDay = "Every Day"
    case everyWeek = "Every Week"
    case every2Weeks = "Every 2 Weeks"
    case everyMonth = "Every Month"
    case everyYear = "Every Year"

    var name: String {
        return self.rawValue
    }

    var identity: String {
        return self.rawValue
    }

    static func createProvider(viewController: UIViewController, selected: RepeatOption) -> EventRadioProvider<RepeatOption> {
        return EventRadioProvider<RepeatOption>(viewController: viewController, selectedOption: selected)
    }

}

class RepeatGroupProvider: AnimatableTableViewGroupProvider {

    var providers: [_AnimatableTableViewMultiNodeProvider] {
        return [self.repeatProvider, self.endRepeatProvider]
    }

    let repeatProvider: EventRadioProvider<RepeatOption>
    let endRepeatProvider: EndRepeatProvider

    init(viewController: UIViewController, minEndDate: Observable<Date>, selectedRepeat: RepeatOption?, endRepeatDate: Date?) {
        self.repeatProvider = RepeatOption.createProvider(viewController: viewController, selected: selectedRepeat ?? RepeatOption.never)
        self.endRepeatProvider = EndRepeatProvider(viewController: viewController, minEndDate: minEndDate, endRepeatDate: endRepeatDate)
    }

    func genteralAnimatableProviders() -> Observable<[_AnimatableTableViewMultiNodeProvider]> {
        return self.repeatProvider.selectedOption.asObservable().map { $0 == .never }.distinctUntilChanged()
            .map { [weak self] isNever in
                guard let `self` = self else { return [] }
                return isNever ? [self.repeatProvider] : [self.repeatProvider, self.endRepeatProvider]
        }
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
    
}
