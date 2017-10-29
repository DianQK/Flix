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

    let endRepeatDate: Variable<Date?> = Variable(nil)

    required init(viewController: UIViewController, minEndDate: Observable<Date>) {
        super.init()
        self.titleLabel.text = "End Repeat"
        self.descLabel.textColor = UIColor(named: "CommentText")

        self.endRepeatDate.asObservable()
            .map { date -> String in
                if let date = date {
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "EEE, MMM d, y"
                    return dateformatter.string(from: date)
                } else {
                    return "Never"
                }
            }
            .bind(to: self.descLabel.rx.text)
            .disposed(by: disposeBag)

        self.tap.asObservable()
            .subscribe(onNext: { [weak viewController, weak self] in
                guard let `self` = self else { return }
                let endRepeatSelectViewController = EndRepeatSelectViewController(endRepeatDate: self.endRepeatDate, minEndDate: minEndDate)
                viewController?.show(endRepeatSelectViewController, sender: nil)
            })
            .disposed(by: disposeBag)
    }

}
