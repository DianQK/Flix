//
//  UniqueCommentTextProvider.swift
//  Example
//
//  Created by DianQK on 02/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import Flix

class UniqueCommentTextProvider: UniqueAnimatableCollectionViewProvider {

    let text: Variable<String>
    let disposeBag = DisposeBag()
    
    init(text: String) {
        self.text = Variable(text)
        self.text.asObservable().bind(to: textLabel.rx.text).disposed(by: disposeBag)
    }
    
    let textLabel = UILabel()

    func onCreate(_ collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: IndexPath) {
        cell.contentView.addSubview(textLabel)
        textLabel.font = UIFont.systemFont(ofSize: 12)
        textLabel.numberOfLines = 0
        textLabel.textColor = UIColor(named: "CommentText")
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 15).isActive = true
        textLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor, constant: 0).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -15).isActive = true
        text.asObservable().skip(1)
            .subscribe(onNext: { [weak collectionView] (_) in
                collectionView?.performBatchUpdates(nil, completion: nil)
            })
            .disposed(by: disposeBag)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, value: UniqueCommentTextProvider) -> CGSize? {
        let height = NSAttributedString(string: value.text.value, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)])
            .boundingRect(with: CGSize(width: collectionView.bounds.width - 30, height: CGFloat.greatestFiniteMagnitude), options: [NSStringDrawingOptions.usesFontLeading, NSStringDrawingOptions.usesLineFragmentOrigin], context: nil).height
        return CGSize(width: collectionView.bounds.width, height: height + 20)
    }

}
