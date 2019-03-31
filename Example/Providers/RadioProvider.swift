//
//  RadioProvider.swift
//  Example
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

class RadioProvider<Option: Equatable & StringIdentifiableType>: AnimatableCollectionViewProvider {

    let options: [Option]
    let checkedOption = BehaviorRelay<Option?>(value: nil)
    let disposeBag = DisposeBag()
//
    typealias Cell = RadioCollectionViewCell
    typealias Value = Option

    init(options: [Option]) {
        self.options = options
    }

    func configureCell(_ collectionView: UICollectionView, cell: RadioCollectionViewCell, indexPath: IndexPath, value: Option) {
        cell.titleLabel.text = String(describing: value)
        checkedOption.asObservable()
            .map { $0 == value }
            .bind(to: cell.isChecked)
            .disposed(by: cell.reuseBag)
    }

    func itemSelected(_ collectionView: UICollectionView, indexPath: IndexPath, value: Option) {
        collectionView.deselectItem(at: indexPath, animated: true)
        checkedOption.accept(value)
    }

    func createValues() -> Observable<[Option]> {
        return Observable.just(options)
    }

    // workaround: Segmentation fault: 11 While emitting IR SIL function "@$s7Example13RadioProviderCyqd__G4Flix033AnimatableCollectionViewMultiNodeC0AaeFP06createE5Nodes7RxSwift10ObservableCySayAE012IdentifiableI0VGGyFTW". for 'createAnimatableNodes()' (in module 'Flix')
    func createAnimatableNodes() -> Observable<[IdentifiableNode]> {
        let providerIdentity = self._flix_identity
        return createValues()
            .map { $0.map { IdentifiableNode(providerIdentity: providerIdentity, valueNode: $0) } }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, value: Option) -> CGSize? {
        return CGSize(width: collectionView.bounds.width, height: 44)
    }
    
}
