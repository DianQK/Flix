//
//  AppsProvider.swift
//  Example
//
//  Created by DianQK on 04/11/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import Flix

class AppTableViewCell: UITableViewCell {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()

    lazy var iconImageView = UIImageView()

    private let leftStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.alignment = .center
        return stackView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        leftStackView.addArrangedSubview(iconImageView)
        leftStackView.addArrangedSubview(titleLabel)

        self.accessoryType = .disclosureIndicator

        self.separatorInset = UIEdgeInsets(top: 0, left: 59, bottom: 0, right: 0)
        self.contentView.addSubview(leftStackView)
        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        leftStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16).isActive = true
        leftStackView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

struct App: StringIdentifiableType, Equatable {

    var identity: String {
        return self.title
    }

    static func ==(lhs: App, rhs: App) -> Bool {
        return lhs.title == rhs.title
    }

    let icon: UIImage
    let title: String

}

class AppsProvider: AnimatableTableViewProvider {

    typealias Cell = AppTableViewCell
    typealias Value = App

    let apps: [App]

    init(apps: [App]) {
        self.apps = apps
    }

    func configureCell(_ tableView: UITableView, cell: AppTableViewCell, indexPath: IndexPath, value: App) {
        cell.iconImageView.image = value.icon
        cell.titleLabel.text = value.title
    }

    func createValues() -> Observable<[App]> {
        return Observable.just(apps)
    }

    func itemSelected(_ tableView: UITableView, indexPath: IndexPath, value: App) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, value: App) -> CGFloat? {
        return 44
    }

}
