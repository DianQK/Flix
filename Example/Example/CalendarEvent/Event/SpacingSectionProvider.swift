//
//  SpacingSectionProvider.swift
//  Example
//
//  Created by wc on 27/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

class SpacingSectionProvider: AnimatableTableViewSectionProvider {

    convenience init(providers: [_AnimatableTableViewMultiNodeProvider], headerHeight: CGFloat, footerHeight: CGFloat) {
        let headerProvider = UniqueCustomTableViewSectionProvider(tableElementKindSection: .header)
        headerProvider.sectionHeight = { _ in return headerHeight }
        let footerProvider = UniqueCustomTableViewSectionProvider(tableElementKindSection: .footer)
        footerProvider.sectionHeight = { _ in return footerHeight }
        self.init(
            providers: providers,
            headerProvider: headerProvider,
            footerProvider: footerProvider
        )
    }

}
