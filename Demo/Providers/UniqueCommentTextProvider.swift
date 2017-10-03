//
//  UniqueCommentTextProvider.swift
//  FormDemo
//
//  Created by wc on 02/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import Flix

struct CommentTextModel: Equatable, StringIdentifiableType {
    
    static func ==(lhs: CommentTextModel, rhs: CommentTextModel) -> Bool {
        return lhs.text == rhs.text
    }
    
    let identity: String
    let text: String
    
}

class CommentTextCollectionCell: UICollectionViewCell {
    
    let textLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(textLabel)
        textLabel.font = UIFont.systemFont(ofSize: 12)
        textLabel.numberOfLines = 0
        textLabel.textColor = UIColor(named: "CommentText")
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        textLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class UniqueCommentTextProvider: AnimatableCollectionViewProvider {
    
    let identity: String // Hashable
    let text: Variable<String>
    let disposeBag = DisposeBag()
    
    init(identity: String, text: String) {
        self.identity = identity
        self.text = Variable(text)
    }
    
    let textLabel = UILabel()
    
    func configureCell(_ collectionView: UICollectionView, cell: CommentTextCollectionCell, indexPath: IndexPath, node: CommentTextModel) {
        cell.textLabel.text = node.text
    }
    
    func tap(_ collectionView: UICollectionView, indexPath: IndexPath, node: CommentTextModel) {
//        print(desc)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, node: CommentTextModel) -> CGSize? {
        let height = NSAttributedString(string: node.text, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)])
            .boundingRect(with: CGSize(width: collectionView.bounds.width - 30, height: CGFloat.greatestFiniteMagnitude), options: [NSStringDrawingOptions.usesFontLeading, NSStringDrawingOptions.usesLineFragmentOrigin], context: nil).height
        return CGSize(width: collectionView.bounds.width, height: height + 20)
    }

    public func genteralNodes() -> Observable<[CommentTextModel]> {
        let identity = self.identity
        return self.text.asObservable().map { [CommentTextModel.init(identity: identity, text: $0)] }
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeInSection section: Int, node: TextModel) -> CGSize? {
//    }

}
