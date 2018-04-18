//
//  MoveCollectionViewController.swift
//  Example
//
//  Created by DianQK on 14/11/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

extension UIColor: StringIdentifiableType {

    public var identity: String {
        return self.description
    }

}

class MoveCollectionViewProvider: AnimatableCollectionViewProvider, CollectionViewMoveable {

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndex: Int, to destinationIndex: Int, value: UIColor) {
        var result = colors.value
        result.remove(at: sourceIndex)
        result.insert(value, at: destinationIndex)
        colors.accept(result)
    }

    func configureCell(_ collectionView: UICollectionView, cell: UICollectionViewCell, indexPath: IndexPath, value: UIColor) {
        cell.backgroundColor = value
    }

    func createValues() -> Observable<[UIColor]> {
        return colors.asObservable()
    }

    typealias Value = UIColor
    typealias Cell = UICollectionViewCell

    let colors = BehaviorRelay(value: [UIColor.black, UIColor.blue, UIColor.red, UIColor.green, UIColor.yellow, UIColor.purple])

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath, value: UIColor) -> CGSize? {
        return CGSize(width: 80, height: 80)
    }

}

class MoveCollectionViewController: CollectionViewController {

    let moveCollectionViewProvider = MoveCollectionViewProvider()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Move"

        let long = UILongPressGestureRecognizer()
        long.rx.event
            .subscribe(onNext: { [unowned collectionView] gesture in
                switch gesture.state {
                case .began:
                    guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView))
                        , let canMoveItemAtIndexPath = collectionView.dataSource?.collectionView?(collectionView, canMoveItemAt: selectedIndexPath)
                        , canMoveItemAtIndexPath else {
                            return
                    }
                    collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
                case .changed:
                    collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view))
                case .ended:
                    collectionView.endInteractiveMovement()
                case .cancelled, .failed, .possible:
                    collectionView.cancelInteractiveMovement()
                }
            })
            .disposed(by: disposeBag)
        self.collectionView.addGestureRecognizer(long)

        self.collectionView.flix.animatable.build([moveCollectionViewProvider])
    }

}
