//
//  EventEditViewController.swift
//  Example
//
//  Created by DianQK on 27/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

extension String {

    var noEmpty: String? {
        return self.isEmpty ? nil : self
    }

}

class EventEditViewController: TableViewController {

    let cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: nil, action: nil)
    let addBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: nil, action: nil)

    private(set) var saved: Observable<CalendarEventObject>! = nil

    init(calendarEvent: CalendarEventObject?) {
        super.init(nibName: nil, bundle: nil)
        let isEdit = calendarEvent != nil
        self.title = isEdit ? "Edit Event" : "New Event"
        self.addBarButtonItem.title = isEdit ? "Done" : "Add"

        self.navigationItem.leftBarButtonItem = cancelBarButtonItem
        self.navigationItem.rightBarButtonItem = addBarButtonItem

        Observable.merge([cancelBarButtonItem.rx.tap.asObservable()]) // remove
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        self.tableView.keyboardDismissMode = .onDrag

        let titleProvider = TextFieldProvider()
        titleProvider.placeholder = "Title"
        titleProvider.text = calendarEvent?.title
        if !isEdit {
            titleProvider.becomeFirstResponder()
        }

        let selectedLocationProvider = SelectedLocationProvider(viewController: self, selected: calendarEvent?.location)

        let baseInfoSectionProvider = SpacingSectionProvider(providers: [titleProvider, selectedLocationProvider], headerHeight: 18, footerHeight: 18)

        let startAndEndDateGroupProvider = StartAndEndDateGroupProvider(
            viewController: self,
            isAllDay: calendarEvent?.isAllDay,
            start: calendarEvent?.startsDate,
            end: calendarEvent?.endRepeatDate
        )
        let repeatGroupProvider = RepeatGroupProvider(
            viewController: self,
            minEndDate: startAndEndDateGroupProvider.endDate,
            selectedRepeat: calendarEvent?.eventRepeat,
            endRepeatDate: calendarEvent?.endRepeatDate
        )
        let dateSectionProvider = SpacingSectionProvider(providers: [startAndEndDateGroupProvider, repeatGroupProvider], headerHeight: 18, footerHeight: 18)

        let calendarProvider = CalendarOption.createProvider(viewController: self, selected: calendarEvent?.calendar ?? CalendarOption(name: "Home"))
        let calendarSectionProvider = SpacingSectionProvider(providers: [calendarProvider], headerHeight: 18, footerHeight: 18)

        let alertProvider = AlertGroupProvider(viewController: self, first: calendarEvent?.alert, second: calendarEvent?.secondAlert)
        let showAsProvider = ShowAsOption.createProvider(viewController: self, selected: calendarEvent?.showAs ?? ShowAsOption.busy)

        let reminderSectionProvider = SpacingSectionProvider(
            providers: [alertProvider, showAsProvider],
            headerHeight: 18, footerHeight: 18
        )

        let urlProvider = TextFieldProvider()
        urlProvider.placeholder = "URL"
        urlProvider.keyboardType = .URL
        urlProvider.text = calendarEvent?.url

        let notesProvider = TextViewProvider()
        notesProvider.placeholder = "Notes"
        notesProvider.text = calendarEvent?.notes

        let commentSectionProvider = SpacingSectionProvider(providers: [urlProvider, notesProvider], headerHeight: 18, footerHeight: 18)

        self.tableView.flix.animatable.build([baseInfoSectionProvider, dateSectionProvider, calendarSectionProvider, reminderSectionProvider, commentSectionProvider])

        let eventTitle = titleProvider.rx.text.map { $0?.noEmpty }
        let eventLocation = selectedLocationProvider.location.asObservable()
        let titleAndLocation = Observable.combineLatest(eventTitle, eventLocation)

        let eventIsAllDay = startAndEndDateGroupProvider.allDaySwitchProvider.uiSwitch.rx.isOn.asObservable()
        let eventStartsDate = startAndEndDateGroupProvider.startProvider.pickerProvider.datePicker.rx.date.asObservable()
        let eventEndsDate = startAndEndDateGroupProvider.endProvider.pickerProvider.datePicker.rx.date.asObservable()
        let eventRepeat = repeatGroupProvider.repeatProvider.selectedOption.asObservable()
        let eventEndRepeatDate = repeatGroupProvider.endRepeatProvider.endRepeatDate.asObservable()
        let reminder = Observable.combineLatest(eventIsAllDay, eventStartsDate, eventEndsDate, eventRepeat, eventEndRepeatDate)

        let eventCalendar = calendarProvider.selectedOption.asObservable()

        let eventAlert = alertProvider.firstAlertProvider.selectedOption.asObservable()
        let eventSecondAlert = alertProvider.secondAlertProvider.selectedOption.asObservable()
        let alert = Observable.combineLatest(eventAlert, eventSecondAlert)

        let eventShowAs = showAsProvider.selectedOption.asObservable()

        let eventUrl = urlProvider.rx.text.asObservable().map { $0?.noEmpty }
        let eventNotes = notesProvider.rx.text.asObservable().map { $0?.noEmpty }
        let comment = Observable.combineLatest(eventUrl, eventNotes)

        Observable
            .combineLatest([
                eventTitle.map { $0?.noEmpty != nil },
                eventLocation.map { $0 != nil },
                eventUrl.map { $0?.noEmpty != nil },
                eventNotes.map { $0?.noEmpty != nil }
                ])
            .map { $0.contains(true) }
            .bind(to: self.addBarButtonItem.rx.isEnabled)
            .disposed(by: disposeBag)

        let newCalendarEvent: Observable<CalendarEventObject> = Observable
            .combineLatest(titleAndLocation, reminder, eventCalendar, alert, eventShowAs, comment)
            .map { (titleAndLocation, reminder, eventCalendar, alert, eventShowAs, comment) -> CalendarEventObject in
                return CalendarEventObject(
                    id: calendarEvent?.id ?? 0,
                    title: titleAndLocation.0 ?? "New Event",
                    location: titleAndLocation.1,
                    isAllDay: reminder.0,
                    startsDate: reminder.1,
                    endsDate: reminder.2,
                    eventRepeat: reminder.3,
                    endRepeatDate: reminder.4,
                    calendar: eventCalendar,
                    alert: alert.0,
                    secondAlert: alert.1,
                    showAs: eventShowAs,
                    url: comment.0,
                    notes: comment.1
                )
            }
            .take(1)

        self.saved = addBarButtonItem.rx.tap.asObservable().flatMap { newCalendarEvent }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension Reactive where Base: EventEditViewController {

    var didCancel: ControlEvent<()> {
        return self.base.cancelBarButtonItem.rx.tap
    }

    static func createWithParent(_ parent: UIViewController?, calendarEvent: CalendarEventObject?) -> Observable<EventEditViewController> {
        return Observable.create { [weak parent] observer in
            let eventEdit = EventEditViewController(calendarEvent: calendarEvent)
            let dismissDisposable = eventEdit.rx
                .didCancel
                .subscribe(onNext: { [weak eventEdit] _ in
                    guard let eventEdit = eventEdit else {
                        return
                    }
                    dismissViewController(eventEdit, animated: true)
                })

            guard let parent = parent else {
                observer.on(.completed)
                return Disposables.create()
            }

            let nav = UINavigationController(rootViewController: eventEdit)
            parent.present(nav, animated: true, completion: nil)
            observer.on(.next(eventEdit))

            return Disposables.create(dismissDisposable, Disposables.create {
                dismissViewController(eventEdit, animated: true)
            })
        }
    }
}
