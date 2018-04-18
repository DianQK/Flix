//
//  FlixStackView.swift
//  Flix
//
//  Created by wc on 24/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public class FlixStackView: UIStackView {

    public private(set) var providers: [FlixStackItemProvider] = []

    public let tableView = UITableView(frame: .zero, style: .grouped)

    private let disposeBag = DisposeBag()

    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        tableView.sectionFooterHeight = 0.1
        tableView.sectionHeaderHeight = 0.1
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0

        for view in self.arrangedSubviews {
            self.removeArrangedSubview(view)
            if let provider = view as? FlixStackItemProvider {
                let height = provider.bounds.height
                provider.itemHeight = { return height }
                providers.append(provider)
            }
        }

        self.addArrangedSubview(tableView)
        tableView.flix.animatable.build(providers)
    }

}
