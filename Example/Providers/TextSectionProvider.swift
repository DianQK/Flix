//
//  TextSectionProvider.swift
//  Example
//
//  Created by DianQK on 01/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

class TextCollectionReusableView: UICollectionReusableView {
    
    let textLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textLabel.font = UIFont.systemFont(ofSize: 12)
        textLabel.numberOfLines = 0
        textLabel.textColor = UIColor(named: "CommentText")
        self.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        textLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class TextSectionProvider: AnimatableSectionPartionCollectionViewProvider, StringIdentifiableType, Equatable {
    
    static func ==(lhs: TextSectionProvider, rhs: TextSectionProvider) -> Bool {
        return true
    }

    func configureSupplementaryView(_ collectionView: UICollectionView, sectionView: TextCollectionReusableView, indexPath: IndexPath, value: TextSectionProvider) {
        if !sectionView.hasConfigured {
            sectionView.hasConfigured = true
        }
        value.text.asObservable()
            .bind(to: sectionView.textLabel.rx.text)
            .disposed(by: disposeBag)
        
        value.text.asObservable().distinctUntilChanged()
            .subscribe(onNext: { [weak collectionView] (text) in
                collectionView?.performBatchUpdates(nil, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    func createSectionPartion() -> Observable<TextSectionProvider?> {
        return Observable.just(self)
    }

    typealias Cell = TextCollectionReusableView
    typealias NodeType = TextSectionProvider

    let collectionElementKindSection: UICollectionElementKindSection
    let text: BehaviorRelay<String>
    let disposeBag = DisposeBag()
    
    init(collectionElementKindSection: UICollectionElementKindSection, text: String) {
        self.collectionElementKindSection = collectionElementKindSection
        self.text = BehaviorRelay(value: text)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeInSection section: Int, value: TextSectionProvider) -> CGSize? {
        let height = NSAttributedString(string: value.text.value, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
            .boundingRect(with: CGSize(width: collectionView.bounds.width - 30, height: CGFloat.greatestFiniteMagnitude), options: [NSStringDrawingOptions.usesFontLeading, NSStringDrawingOptions.usesLineFragmentOrigin], context: nil).height
        return CGSize(width: collectionView.bounds.width, height: height + 20)
    }
}
