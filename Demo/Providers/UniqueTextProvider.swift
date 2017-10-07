//
//  UniqueTextProvider.swift
//  FormDemo
//
//  Created by DianQK on 01/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import Flix

struct UniqueTextProvider: UniqueAnimatableCollectionViewProvider {

    let identity: String // Hashable
    let title: String
    let desc: String
    
    init(identity: String, title: String, desc: String) {
        self.identity = identity
        self.title = title
        self.desc = desc
    }
    
    let titleLabel = UILabel()
    let descLabel = UILabel()
    let disclosureIndicatorImageView = UIImageView(image: #imageLiteral(resourceName: "Disclosure Indicator"))

    func onCreate(_ collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: IndexPath) {
        cell.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor, constant: 0).isActive = true
        titleLabel.text = title
        
        descLabel.textColor = UIColor(named: "CommentText")
        descLabel.text = desc
        
        let stackView = UIStackView(arrangedSubviews: [descLabel, disclosureIndicatorImageView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 11
        
        cell.contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -15).isActive = true
        stackView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: 0).isActive = true

        cell.backgroundColor = UIColor.white
    }
    
    func tap(_ collectionView: UICollectionView, indexPath: IndexPath, value: UniqueTextProvider) {
        print(desc)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, value: UniqueTextProvider) -> CGSize? {
        return CGSize(width: collectionView.bounds.width, height: 44)
    }
    
}
