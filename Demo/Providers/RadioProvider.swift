//
//  RadioProvider.swift
//  FormDemo
//
//  Created by DianQK on 02/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

class RadioCollectionViewCell: UICollectionViewCell {
    
    let titleLabel = UILabel()
    let checkImageView = UIImageView(image: #imageLiteral(resourceName: "Checkmark"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor, constant: 0).isActive = true
        
        self.contentView.addSubview(checkImageView)
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15).isActive = true
        checkImageView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: 0).isActive = true
        checkImageView.isHidden = true
        
        self.backgroundColor = UIColor.white
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
    }
    
    var reuseBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseBag = DisposeBag()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isChecked: Binder<Bool> {
        return Binder(self, binding: { (cell, isChecked) in
            cell.checkImageView.isHidden = !isChecked
        })
    }

}

struct RadioProvider<Option: Equatable & StringIdentifiableType>: AnimatableCollectionViewProvider {
    
    let identity: String // Hashable
    let options: [Option]
    let checkedOption = Variable<Option?>(nil)
    let disposeBag = DisposeBag()
    
    typealias Cell = RadioCollectionViewCell
    typealias Value = Option
    
    init(identity: String, options: [Option]) {
        self.identity = identity
        self.options = options
    }
    
    func configureCell(_ collectionView: UICollectionView, cell: RadioCollectionViewCell, indexPath: IndexPath, node: Option) {
        cell.titleLabel.text = String(describing: node)
        checkedOption.asObservable()
            .map { $0 == node }
            .bind(to: cell.isChecked)
            .disposed(by: cell.reuseBag)
    }
    
    func tap(_ collectionView: UICollectionView, indexPath: IndexPath, node: Value) {
        collectionView.deselectItem(at: indexPath, animated: true)
        checkedOption.value = node
    }
    
    func genteralNodes() -> Observable<[Value]> {
        return Observable.just(options)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, node: Value) -> CGSize? {
        return CGSize(width: collectionView.bounds.width, height: 44)
    }
    
}
