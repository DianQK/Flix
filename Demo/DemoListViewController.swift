//
//  DemoListViewController.swift
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

class DemoListViewController: CollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Demo"
        
        typealias Model = TextListProviderModel<UIViewController.Type>
        
        let textListProvider = TextListProvider(
            identity: "textListProvider",
            items: [
                Model(title: "Photos", desc: "", value: PhotoSettingsViewController.self),
                Model(title: "勿扰模式", desc: "", value: DoNotDisturbSettingsViewController.self),
                Model(title: "登录示例", desc: "", value: LoginViewController.self),
                Model(title: "GitHub Signup", desc: "", value: GitHubSignupViewController.self),
                Model(title: "嵌套表单", desc: "", value: NestFormViewController.self),
                Model(title: "删除示例", desc: "", value: DeleteItemViewController.self)
            ]
        )
        textListProvider.tapped
            .subscribe(onNext: { [unowned self] (model) in
                self.show(model.value.init(), sender: nil)
            })
            .disposed(by: disposeBag)
        
        self.collectionViewBuilder = AnimatableCollectionViewBuilder(
            collectionView: collectionView,
            providers: [textListProvider]
        )

    }

}
