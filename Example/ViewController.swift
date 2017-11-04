//
//  ViewController.swift
//  Example
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.lightGray
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        collectionView.backgroundColor = UIColor(named: "Background")
        
        let viewLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        viewLayout.minimumLineSpacing = 0.5
        viewLayout.estimatedItemSize = CGSize.zero
        
        collectionView.alwaysBounceVertical = true
        
    }
}

class TableViewController: UIViewController {
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
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
