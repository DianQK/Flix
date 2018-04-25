//
//  SelectTimeZoneViewController.swift
//  Example
//
//  Created by wc on 29/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

class TitleTableViewCell: UITableViewCell {

    let titleLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -20).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private class TimeZonesProvider: AnimatableTableViewProvider {

    func configureCell(_ tableView: UITableView, cell: TitleTableViewCell, indexPath: IndexPath, value: String) {
        cell.titleLabel.text = value
    }

    func createValues() -> Observable<[String]> {
        let knownTimeZoneNames = TimeZone.knownTimeZoneIdentifiers
        return self.query.map { query in knownTimeZoneNames.filter { $0.contains(query) } }
    }

    let query: Observable<String>
    var timeZoneSelected: Observable<TimeZone> {
        return self.event.modelSelected.map { TimeZone(identifier: $0)! }
    }

    init(query: Observable<String>) {
        self.query = query
    }

    typealias Value = String
    typealias Cell = TitleTableViewCell

}

class SelectTimeZoneViewController: UIViewController {

    let searchBar = UISearchBar()
    let tableView = UITableView(frame: .zero, style: .plain)

    let disposeBag = DisposeBag()

    let timeZoneSelected = PublishSubject<TimeZone>()

    init(currentTimeZone: TimeZone) {
        super.init(nibName: nil, bundle: nil)
        self.searchBar.text = currentTimeZone.identifier
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Time Zone"
        self.searchBar.placeholder = "Search"
        self.searchBar.tintColor = UIColor(named: "Bittersweet")
        _ = self.searchBar.becomeFirstResponder()

        self.view.backgroundColor = UIColor.white

        self.tableView.sectionHeaderHeight = CGFloat.leastNonzeroMagnitude
        self.tableView.sectionFooterHeight = CGFloat.leastNonzeroMagnitude
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.rowHeight = 44
        self.tableView.backgroundColor = UIColor(named: "Background")
        self.tableView.separatorColor = UIColor(named: "Background")

        self.view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 55).isActive = true

        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: self.searchBar.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo:  self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        let timeZonesProvider = TimeZonesProvider(query: self.searchBar.rx.text.orEmpty.asObservable())

        timeZonesProvider.timeZoneSelected.asObservable()
            .subscribe(onNext: { [weak self] (timeZone) in
                guard let `self` = self else { return }
                self.timeZoneSelected.onNext(timeZone)
                self.timeZoneSelected.onCompleted()
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        self.tableView.flix.build([timeZonesProvider])

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timeZoneSelected.onCompleted()
    }

}
