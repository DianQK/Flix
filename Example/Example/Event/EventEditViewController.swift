//
//  EventEditViewController.swift
//  Example
//
//  Created by wc on 27/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

class EventEditViewController: TableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Event"

        let titleProvider = TextFieldProvider()
        titleProvider.tintColor = UIColor(named: "Deep Carmine Pink")
        titleProvider.placeholder = "Title"

        let selectedLocationProvider = SelectedLocationProvider(viewController: self)

        let baseInfoSectionProvider = SpacingSectionProvider(providers: [titleProvider, selectedLocationProvider], headerHeight: 18, footerHeight: 18)
        let dateSectionProvider = SpacingSectionProvider(providers: [StartAndEndDateGroupProvider(viewController: self)], headerHeight: 18, footerHeight: 18)

        let reminderSectionProvider = SpacingSectionProvider(
            providers: [
                AlertGroupProvider(viewController: self),
                ShowAsOption.createProvider(viewController: self, selected: ShowAsOption.busy)
            ],
            headerHeight: 18, footerHeight: 18
        )

        self.tableView.flix.animatable.build([baseInfoSectionProvider, dateSectionProvider, reminderSectionProvider])
    }

}
