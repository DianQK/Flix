//
//  TextListProvider.swift
//  FormDemo
//
//  Created by DianQK on 01/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

class TextCollectionViewCell: UICollectionViewCell {
    
    let titleLabel = UILabel()
    let descLabel = UILabel()
    let disclosureIndicatorImageView = UIImageView(image: #imageLiteral(resourceName: "Disclosure Indicator"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 20).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0).isActive = true
        descLabel.textColor = UIColor(named: "CommentText")
        
        let stackView = UIStackView(arrangedSubviews: [descLabel, disclosureIndicatorImageView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 11
        
        self.contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15).isActive = true
        stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
        
        self.backgroundColor = UIColor.white
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

struct TextListProviderModel<Value>: Equatable, StringIdentifiableType {
    let title: String
    let desc: String
    let value: Value
    
    var identity: String {
        return self.title
    }
    
    static func ==(lhs: TextListProviderModel, rhs: TextListProviderModel) -> Bool {
        return lhs.desc == rhs.desc
    }
}

struct TextListProvider<Value>: AnimatableCollectionViewProvider {
    
    typealias Model = TextListProviderModel<Value>
    
    let identity: String // Hashable
    let items: [Model]
    let isHidden = Variable(false)
    
    typealias CellType = TextCollectionViewCell
    typealias NodeType = Model
    
    let _tap = PublishSubject<Model>()
    
    var tapped: Observable<Model> {
        return _tap.asObservable()
    }
    
    init(identity: String, items: [Model]) {
        self.identity = identity
        self.items = items
    }
    
    func configureCell(_ collectionView: UICollectionView, cell: TextCollectionViewCell, indexPath: IndexPath, node: NodeType) {
        cell.titleLabel.text = node.title
        cell.descLabel.text = node.desc
    }
    
    func tap(_ collectionView: UICollectionView, indexPath: IndexPath, node: NodeType) {
        _tap.onNext(node)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func genteralNodes() -> Observable<[Model]> {
        let items = self.items
        return isHidden.asObservable().distinctUntilChanged().map { isHidden in isHidden ? [] : items }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, node: NodeType) -> CGSize? {
        return CGSize(width: collectionView.bounds.width, height: 44)
    }
    
}
