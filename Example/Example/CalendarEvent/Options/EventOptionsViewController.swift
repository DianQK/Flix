//
//  EventOptionsViewController.swift
//  Example
//
//  Created by DianQK on 29/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

class EventOptionsProvider<T: EventOptionType>: AnimatableTableViewProvider {

    func configureCell(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath, value: T) {
        if !cell.hasConfigured {
            cell.hasConfigured = true
            let titleLabel = UILabel()
            cell.contentView.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20).isActive = true
            titleLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            titleLabel.text = value.name
            if let selectedOption = selectedOption, selectedOption == value {
                cell.accessoryType = .checkmark
            }
        }
    }

    func createValues() -> Observable<[T]> {
        return Observable.just(options)
    }

    let options: [T]
    let selectedOption: T?

    init(options: [T], selectedOption: T?) {
        self.options = options
        self.selectedOption = selectedOption
    }

    typealias Value = T
    typealias Cell = UITableViewCell

}

class EventOptionsViewController<T: EventOptionType>: TableViewController {

    let selectedOption: T?
    let optionSelected = PublishSubject<T>()

    init(selectedOption: T?) {
        self.selectedOption = selectedOption
        super.init(nibName: nil, bundle: nil)
        self.title = T.title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let selectedOption = self.selectedOption

        let providers = T.allOptions.map { EventOptionsProvider(options: $0, selectedOption: selectedOption) }

        for provider in providers {
            provider.event.modelSelected.asObservable()
                .subscribe(onNext: { [weak self] (option) in
                    guard let `self` = self else { return }
                    self.optionSelected.onNext(option)
                    self.optionSelected.onCompleted()
                    self.navigationController?.popViewController(animated: true)
                })
                .disposed(by: disposeBag)
        }

        let sectionProviders = providers
            .map { SpacingSectionProvider(providers: [$0], headerHeight: 18, footerHeight: 18) }

        self.tableView.flix.build(sectionProviders)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.optionSelected.onCompleted()
    }

}
