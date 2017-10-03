//
//  UniqueSelectProvider.swift
//  FormDemo
//
//  Created by wc on 01/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import Flix

struct UniqueSelectProvider: UniqueAnimatableCollectionViewProvider {

    func tap(_ collectionView: UICollectionView, indexPath: IndexPath, node: UniqueSelectProvider) {
        
    }
    
    let identity: String // Hashable
    let titleLabel = UILabel()
    
    init(identity: String) {
        self.identity = identity
    }
    
    func onCreate(_ collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: IndexPath) {
        
        cell.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 15).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor, constant: 0).isActive = true
        cell.backgroundColor = UIColor.white
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, node: UniqueSelectProvider) -> CGSize? {
        return CGSize(width: collectionView.bounds.width, height: 44)
    }
    
}
