//
//  UniqueTextInputProvider.swift
//  FormDemo
//
//  Created by DianQK on 03/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import Flix

struct UniqueTextInputProvider: UniqueAnimatableCollectionViewProvider {
    
    let identity: String // Hashable
    let textView = UITextView()
    let disposeBag = DisposeBag()
    
    init(identity: String) {
        self.identity = identity
    }
    
    func onCreate(_ collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: IndexPath) {
        cell.contentView.addSubview(textView)
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 0).isActive = true
        textView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 0).isActive = true
        textView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: 0).isActive = true
        textView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: 0).isActive = true
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 15, bottom: 0, right: 15)

        cell.backgroundColor = UIColor.white
        
        textView.rx.text.orEmpty.changed.distinctUntilChanged()
            .subscribe(onNext: { [weak collectionView] (text) in
                collectionView?.performBatchUpdates(nil, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    func tap(_ collectionView: UICollectionView, indexPath: IndexPath, node: UniqueTextInputProvider) {
        //        print(desc)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, node: UniqueTextInputProvider) -> CGSize? {
        let height = NSAttributedString(string: node.textView.text, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17)]).boundingRect(with: CGSize(width: collectionView.bounds.width - 30, height: CGFloat.greatestFiniteMagnitude), options: [NSStringDrawingOptions.usesFontLeading, .usesLineFragmentOrigin], context: nil).height
        return CGSize(width: collectionView.bounds.width, height: max(44, height + 24))
    }

}
