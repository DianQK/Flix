//
//  EndRepeatProvider.swift
//  Example
//
//  Created by wc on 29/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

class EndRepeatProvider: TitleDescProvider {

    required init(viewController: UIViewController) {
        super.init()
        self.titleLabel.text = "End Repeat"
        self.descLabel.text = "=。="
    }

}
