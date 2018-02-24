//
//  EventListViewController.swift
//  Example
//
//  Created by wc on 27/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

class EventListProvider: AnimatableTableViewProvider {

    typealias Cell = TitleTableViewCell
    typealias Value = CalendarEventObject

    let objects = BehaviorRelay<[CalendarEventObject]>(value: [])

    func configureCell(_ tableView: UITableView, cell: TitleTableViewCell, indexPath: IndexPath, value: CalendarEventObject) {
        cell.titleLabel.text = value.title
        cell.accessoryType = .disclosureIndicator
    }

    func genteralValues() -> Observable<[CalendarEventObject]> {
        return self.objects.asObservable()
    }

    var addObject: Binder<CalendarEventObject> {
        return Binder(self, binding: { (provider, object) in
            if object.id == 0 {
                var object = object
                let id = provider.objects.value.map { $0.id }.max() ?? 1
                object.id = id
                provider.objects.accept(provider.objects.value + [object])
            } else {
                provider.objects.accept(provider.objects.value.map { (old) -> CalendarEventObject in
                    return old.id == object.id ? object : old
                })
            }
        })
    }

    var tapObject = PublishSubject<CalendarEventObject>()

    func tap(_ tableView: UITableView, indexPath: IndexPath, value: CalendarEventObject) {
        self.tapObject.onNext(value)
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

class EventListViewController: TableViewController {

    let provider = EventListProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "All Events"

        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = addBarButtonItem
        Observable.merge([
            addBarButtonItem.rx.tap.map { nil as CalendarEventObject? },
            provider.tapObject.map { $0 as CalendarEventObject? }
            ])
            .flatMapLatest { [weak self] event in
                return EventEditViewController.rx.createWithParent(self, calendarEvent: event)
                    .flatMap({ $0.saved.asObservable() })
                    .take(1)
            }
            .bind(to: provider.addObject)
            .disposed(by: disposeBag)

        provider.objects.asObservable().map { $0.isEmpty }
            .subscribe(onNext: { [weak self] (isEmpty) in
                if isEmpty {
                    let backgroundImageView = UIImageView(image: #imageLiteral(resourceName: "Flix Icon"))
                    backgroundImageView.contentMode = .center
                    backgroundImageView.backgroundColor = UIColor.white
                    self?.tableView.backgroundView = backgroundImageView
                } else {
                    self?.tableView.backgroundView = nil
                }
            })
            .disposed(by: disposeBag)

        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)

        self.tableView.flix.animatable.build([provider])
    }

}
