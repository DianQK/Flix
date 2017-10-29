//
//  EventEditViewController.swift
//  Example
//
//  Created by wc on 27/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

class EventEditViewController: TableViewController {

    let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: nil, action: nil)
    let addBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: nil, action: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Event"

        self.navigationItem.leftBarButtonItem = cancelBarButtonItem
        self.navigationItem.rightBarButtonItem = addBarButtonItem

        Observable.merge([cancelBarButtonItem.rx.tap.asObservable(), addBarButtonItem.rx.tap.asObservable()]) // remove
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        self.tableView.keyboardDismissMode = .onDrag

        let titleProvider = TextFieldProvider()
        titleProvider.placeholder = "Title"

        let selectedLocationProvider = SelectedLocationProvider(viewController: self)

        let baseInfoSectionProvider = SpacingSectionProvider(providers: [titleProvider, selectedLocationProvider], headerHeight: 18, footerHeight: 18)

        let startAndEndDateGroupProvider = StartAndEndDateGroupProvider(viewController: self)
        let repeatGroupProvider = RepeatGroupProvider(viewController: self, minEndDate: startAndEndDateGroupProvider.endDate)
        let dateSectionProvider = SpacingSectionProvider(providers: [startAndEndDateGroupProvider, repeatGroupProvider], headerHeight: 18, footerHeight: 18)

        let calendarSectionProvider = SpacingSectionProvider(providers: [CalendarOption.createProvider(viewController: self, selected: CalendarOption(name: "Home"))], headerHeight: 18, footerHeight: 18)

        let reminderSectionProvider = SpacingSectionProvider(
            providers: [
                AlertGroupProvider(viewController: self),
                ShowAsOption.createProvider(viewController: self, selected: ShowAsOption.busy)
            ],
            headerHeight: 18, footerHeight: 18
        )

        let urlProvider = TextFieldProvider()
        urlProvider.placeholder = "URL"
        urlProvider.keyboardType = .URL

        let notesProvider = TextViewProvider()
        notesProvider.placeholder = "Notes"

        let commentSectionProvider = SpacingSectionProvider(providers: [urlProvider, notesProvider], headerHeight: 18, footerHeight: 18)

        self.tableView.flix.animatable.build([baseInfoSectionProvider, dateSectionProvider, calendarSectionProvider, reminderSectionProvider, commentSectionProvider])
    }

}
