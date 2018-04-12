//
//  UniqueCommentTextProvider.swift
//  Example
//
//  Created by DianQK on 02/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

class UniqueCommentTextProvider: UniqueCustomCollectionViewProvider {


    let textLabel = UILabel()

    let text: BehaviorRelay<String>
    let disposeBag = DisposeBag()
    
    required init(text: String) {
        self.text = BehaviorRelay(value: text)
        super.init()
        self.text.asObservable().bind(to: textLabel.rx.text).disposed(by: disposeBag)

        self.contentView.addSubview(textLabel)
        textLabel.font = UIFont.systemFont(ofSize: 12)
        textLabel.numberOfLines = 0
        textLabel.textColor = UIColor(named: "CommentText")
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        textLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15).isActive = true
        self.text.asObservable()
            .subscribe(onNext: { [weak self] (_) in
                self?.collectionView?.performBatchUpdates(nil, completion: nil)
            })
            .disposed(by: disposeBag)
    }

    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, value: UniqueCustomCollectionViewProvider) -> CGSize? {
        let height = NSAttributedString(string: self.text.value, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)])
            .boundingRect(with: CGSize(width: collectionView.bounds.width - 30, height: CGFloat.greatestFiniteMagnitude), options: [NSStringDrawingOptions.usesFontLeading, NSStringDrawingOptions.usesLineFragmentOrigin], context: nil).height
        return CGSize(width: collectionView.bounds.width, height: height + 20)
    }

}
