//
//  DoNotDisturbSettingsViewController.swift
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

class DoNotDisturbSettingsViewController: CollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Do Not Disturb"
        
        var providers: [_AnimatableCollectionViewMultiNodeProvider] = []
        
        let doNotDisturbProvider = UniqueSwitchProvider()
        doNotDisturbProvider.titleLabel.text = "Do Not Disturb"
        providers.append(doNotDisturbProvider)
        
        let doNotDisturbCommnetProvider = UniqueCommentTextProvider(
            text: "When Do Not Disturb is enabled, calls and alerts that arrive while locked will be silenced, and a moon icon will appear in the status bar."
        )
        providers.append(doNotDisturbCommnetProvider)
        
        let scheduledProvider = UniqueSwitchProvider()
        scheduledProvider.titleLabel.text = "Scheduled"
        providers.append(scheduledProvider)
        
        let slienceTitleProvider = UniqueCommentTextProvider(
            text: "SLIENCE"
        )
        providers.append(slienceTitleProvider)
        
        enum SlienceMode: String, StringIdentifiableType, Equatable, CustomStringConvertible {
            case always
            case whileLocked
            
            var identity: String {
                return self.rawValue
            }
            
            var description: String {
                switch self {
                case .always:
                    return "Always"
                case .whileLocked:
                    return "While iPhone is locked"
                }
            }
            
            var comment: String {
                switch self {
                case .always:
                    return "Incoming calls and notifications will be silenced while iPhone is either locked or unlocked."
                case .whileLocked:
                    return "Incoming calls and notifications will be silenced while iPhone is locked."
                }
            }
        }
        
        let radioProvider = RadioProvider(options: [SlienceMode.always, SlienceMode.whileLocked])
        radioProvider.checkedOption.value = SlienceMode.always
        providers.append(radioProvider)
        
        let slienceCommentProvider = UniqueCommentTextProvider(
            text: ""
        )
        radioProvider.checkedOption.asObservable()
            .map { (option) -> String in
                return option?.comment ?? ""
            }
            .bind(to: slienceCommentProvider.text)
            .disposed(by: disposeBag)
        providers.append(slienceCommentProvider)
        
        let allowCallsFromTitleProvider = UniqueCommentTextProvider(
            text: "PHONE"
        )
        providers.append(allowCallsFromTitleProvider)
        let allowCallsFromProvider = UniqueTextProvider(
            title: "Allow Calls From",
            desc: "Everyone"
        )
        providers.append(allowCallsFromProvider)
        let allowCallsFromCommentProvider = UniqueCommentTextProvider(
            text: "When in Do Not Disturb, allow incoming calls from everyone."
        )
        providers.append(allowCallsFromCommentProvider)
        
        self.collectionView.flix.animatable.build(providers)
    }
    
}
