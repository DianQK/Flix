//
//  DoNotDisturbSettingsViewController.swift
//  FormDemo
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
        
        title = "勿扰模式"
        
        var providers: [_AnimatableCollectionViewMultiNodeProvider] = []
        
        let doNotDisturbProvider = UniqueSwitchProvider(identity: "doNotDisturbProvider")
        doNotDisturbProvider.titleLabel.text = "勿扰模式"
        providers.append(doNotDisturbProvider)
        
        let doNotDisturbCommnetProvider = UniqueCommentTextProvider(
            identity:"doNotDisturbCommnetProvider",
            text: "“勿扰模式启用后，屏幕锁定时的来电和提醒将被设为静音，而状态栏中将出现月亮图标。”"
        )
        providers.append(doNotDisturbCommnetProvider)
        
        let scheduledProvider = UniqueSwitchProvider(identity: "scheduledProvider")
        scheduledProvider.titleLabel.text = "设定时间"
        providers.append(scheduledProvider)
        
        let slienceTitleProvider = UniqueCommentTextProvider(
            identity:"slienceTitleProvider",
            text: "静音模式："
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
                    return "始终"
                case .whileLocked:
                    return "当 iPhone 已锁定时"
                }
            }
            
            var comment: String {
                switch self {
                case .always:
                    return "无论 iPhone 是否已锁定，来电和通知都将静音。"
                case .whileLocked:
                    return "iPhone 被锁定时，来电和通知都将静音。"
                }
            }
        }
        
        let radioProvider = RadioProvider(identity: "radioProvider", options: [SlienceMode.always, SlienceMode.whileLocked])
        radioProvider.checkedOption.value = SlienceMode.always
        providers.append(radioProvider)
        
        let slienceCommentProvider = UniqueCommentTextProvider(
            identity:"slienceCommentProvider",
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
            identity: "allowCallsFromTitleProvider",
            text: "电话"
        )
        providers.append(allowCallsFromTitleProvider)
        let allowCallsFromProvider = UniqueTextProvider(
            identity: "allowCallsFromProvider",
            title: "允许以下来电",
            desc: "所有联系人"
        )
        providers.append(allowCallsFromProvider)
        let allowCallsFromCommentProvider = UniqueCommentTextProvider(
            identity: "allowCallsFromCommentProvider",
            text: "处于”勿扰模式”时，允许联系人来电。"
        )
        providers.append(allowCallsFromCommentProvider)
        
        self.collectionViewService = AnimatableCollectionViewService(
            collectionView: collectionView,
            providers: providers
        )
        
    }
    
}

