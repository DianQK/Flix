//
//  ProfileProvider.swift
//  Example
//
//  Created by wc on 04/11/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import Flix

class ProfileProvider: UniqueAnimatableTableViewProvider {

    let avatarImageView = UIImageView()
    let nameLabel = UILabel()
    let subTitleLabel = UILabel()

    init(avatar: UIImage, name: String) {
        avatarImageView.image = avatar
        nameLabel.text = name

        nameLabel.font = UIFont.systemFont(ofSize: 22)

        subTitleLabel.font = UIFont.systemFont(ofSize: 13)
        subTitleLabel.text = "Apple ID, iCloud, iTunes & App Store"
    }

    func onCreate(_ tableView: UITableView, cell: UITableViewCell, indexPath: IndexPath) {
        cell.accessoryType = .disclosureIndicator
        cell.contentView.addSubview(avatarImageView)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 15).isActive = true
        avatarImageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true

        cell.contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 15).isActive = true
        nameLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 14).isActive = true

        cell.contentView.addSubview(subTitleLabel)
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        subTitleLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -17).isActive = true
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath, value: ProfileProvider) -> CGFloat? {
        return 80
    }

    func tap(_ tableView: UITableView, indexPath: IndexPath, value: ProfileProvider) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
