//
//  EmptyViewController.swift
//  Example
//
//  Created by DianQK on 2018/4/25.
//  Copyright © 2018 DianQK. All rights reserved.
//

import UIKit
import Flix
import RxSwift
import RxCocoa

class EmptyContentTableViewProvider: SingleUITableViewCellProvider {

    let emptyLabel = UILabel()

    override init() {
        super.init()
        self.contentView.addSubview(emptyLabel)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
        emptyLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true

        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.text = "Empty\n Tap to reload"
        whenGetCell { (cell) in
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, value: SingleTableViewCellProvider<UITableViewCell>) -> CGFloat? {
        return tableView.frame.height - tableView.safeAreaInsets.top
    }

}

protocol EmptyListTableViewProvider: AnimatableTableViewMultiNodeProvider {

    var isEmpty: Observable<Bool> { get }

    func refresh()

}

extension Reactive where Base: EmptyListTableViewProvider {

    var refresh: Binder<()> {
        return Binder(self.base, binding: { (provider, _) in
            provider.refresh()
        })
    }

}

class EmptyContainerGroupTableViewProvider<ContentProvider: EmptyListTableViewProvider>: AnimatableTableViewGroupProvider {

    let contentProvider: ContentProvider

    let emptyContentProvider = EmptyContentTableViewProvider()

    var providers: [_AnimatableTableViewMultiNodeProvider] {
        return [self.contentProvider, self.emptyContentProvider]
    }

    let disposeBag = DisposeBag()

    init(contentProvider: ContentProvider) {
        self.contentProvider = contentProvider

        self.emptyContentProvider.event.selectedEvent
            .bind(to: self.contentProvider.rx.refresh)
            .disposed(by: disposeBag)

        self.contentProvider.isEmpty.map { !$0 }
            .bind(to: self.emptyContentProvider.rx.isHidden)
            .disposed(by: disposeBag)
    }

    func createAnimatableProviders() -> Observable<[_AnimatableTableViewMultiNodeProvider]> {
        return Observable.just([contentProvider, emptyContentProvider])
    }

}

class TextListTableViewProvider: AnimatableTableViewProvider, EmptyListTableViewProvider {

    func configureCell(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath, value: String) {
        cell.textLabel?.text = value
    }

    func itemSelected(_ tableView: UITableView, indexPath: IndexPath, value: String) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func createValues() -> Observable<[String]> {
        return self.values.asObservable()
    }

    var isEmpty: Observable<Bool> {
        return self.values.map { $0.isEmpty }
    }

    func refresh() {
        self.values.accept((1...20).map(String.init))
    }

    func clean() {
        self.values.accept([])
    }

    let values = BehaviorRelay<[String]>(value: [])

    typealias Value = String
    typealias Cell = UITableViewCell

}

class EmptyViewController: TableViewController {

    let textListTableViewProvider = TextListTableViewProvider()
    let cleanBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: nil, action: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "List"

        self.navigationItem.rightBarButtonItem = cleanBarButtonItem

        self.cleanBarButtonItem.rx.tap
            .subscribe(onNext: self.textListTableViewProvider.clean)
            .disposed(by: disposeBag)

        self.tableView.flix.animatable.build([
            EmptyContainerGroupTableViewProvider(contentProvider: self.textListTableViewProvider)
            ])
    }

}
