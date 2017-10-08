//
//  ViewController.swift
//  Demo
//
//  Created by DianQK on 03/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Flix
import RxKeyboard

class CollectionViewController: UIViewController {
    
    let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
    let disposeBag = DisposeBag()
    
    var collectionViewBuilder: AnimatableCollectionViewBuilder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.lightGray
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        collectionView.backgroundColor = UIColor(named: "Background")
        
        let viewLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        viewLayout.minimumLineSpacing = 0.5
        viewLayout.estimatedItemSize = CGSize.zero
        
        collectionView.alwaysBounceVertical = true
        
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
    }
}


class TableViewController: UIViewController {
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    let disposeBag = DisposeBag()
    
    var tableViewBuilder: AnimatableTableViewBuilder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        tableView.backgroundColor = UIColor(named: "Background")
        tableView.separatorColor = UIColor(named: "Background")
        tableView.rowHeight = 44
        tableView.sectionFooterHeight = 0.1
        tableView.sectionHeaderHeight = 0.1
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [unowned self] keyboardVisibleHeight in
                self.tableView.contentInset.bottom = keyboardVisibleHeight
                self.tableView.scrollIndicatorInsets.bottom = keyboardVisibleHeight
            })
            .disposed(by: disposeBag)

    }

}

