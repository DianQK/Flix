//
//  SwitchProvider.swift
//  Example
//
//  Created by DianQK on 04/11/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import Flix

class BaseTableViewCellProvider: SingleUITableViewCellProvider {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()

    lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
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

    private let titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 1
        stackView.alignment = UIStackView.Alignment.leading
        return stackView
    }()

    init(title: String, subTitle: String?, icon: UIImage?) {
        super.init()
        if let icon = icon {
            iconImageView.image = icon
            leftStackView.addArrangedSubview(iconImageView)
        }
        leftStackView.addArrangedSubview(titleStackView)
        titleLabel.text = title
        titleStackView.addArrangedSubview(titleLabel)
        if let subTitle = subTitle {
            subTitleLabel.text = subTitle
            titleStackView.addArrangedSubview(subTitleLabel)
        }

        self.separatorInset = UIEdgeInsets(top: 0, left: iconImageView.image == nil ? 16 : 59, bottom: 0, right: 0)
        self.contentView.addSubview(leftStackView)
        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        leftStackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16).isActive = true
        leftStackView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
    }

    func itemSelected(_ tableView: UITableView, indexPath: IndexPath, value: BaseTableViewCellProvider) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

class SwitchTableViewCellProvider: BaseTableViewCellProvider {

    let uiSwitch = UISwitch()

    init(title: String, subTitle: String? = nil, icon: UIImage?, isOn: Bool) {
        super.init(title: title, subTitle: subTitle, icon: icon)
        uiSwitch.isOn = isOn
    }

    override func onCreate(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        super.onCreate(tableView, cell: cell, indexPath: indexPath)
        cell.selectionStyle = .none
        cell.accessoryType = .none
        cell.contentView.addSubview(uiSwitch)
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        uiSwitch.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16).isActive = true
        uiSwitch.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
    }

}

class DescriptionTableViewCellProvider: BaseTableViewCellProvider {

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor.gray
        return label
    }()

    init(title: String, subTitle: String? = nil, icon: UIImage?, description: String? = nil) {
        super.init(title: title, subTitle: subTitle, icon: icon)
        descriptionLabel.text = description
    }

    override func onCreate(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        super.onCreate(tableView, cell: cell, indexPath: indexPath)
        cell.selectionStyle = .default
        cell.accessoryType = .disclosureIndicator
        cell.contentView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: 0).isActive = true
        descriptionLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
    }

}
