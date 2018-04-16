//
//  ProfileProvider.swift
//  Example
//
//  Created by wc on 04/11/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import Flix

class ProfileProvider: SingleUITableViewCellProvider {

    let avatarImageView = UIImageView()
    let nameLabel = UILabel()
    let subTitleLabel = UILabel()

    init(avatar: UIImage, name: String) {
        super.init()
        avatarImageView.image = avatar
        nameLabel.text = name

        nameLabel.font = UIFont.systemFont(ofSize: 22)

        subTitleLabel.font = UIFont.systemFont(ofSize: 13)
        subTitleLabel.text = "Apple ID, iCloud, iTunes & App Store"

        self.accessoryType = .disclosureIndicator
        self.contentView.addSubview(avatarImageView)
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        avatarImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true

        self.contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 15).isActive = true
        nameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 14).isActive = true

        self.contentView.addSubview(subTitleLabel)
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        subTitleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -17).isActive = true

        itemHeight = { _ in 80 }
    }

}
