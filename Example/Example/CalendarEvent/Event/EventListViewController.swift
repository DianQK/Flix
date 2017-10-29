//
//  EventListViewController.swift
//  Example
//
//  Created by wc on 27/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class EventListViewController: TableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "All Events"

        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = addBarButtonItem
        addBarButtonItem.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.present(UINavigationController(rootViewController: EventEditViewController()), animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

    }

}
