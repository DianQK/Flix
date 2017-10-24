//
//  ExampleListViewController.swift
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

class ExampleListViewController: CollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        typealias Model = TextListProviderModel<UIViewController.Type>
        
        let iconProvider = UniqueCustomCollectionViewProvider()
        let iconImageView = UIImageView(image: #imageLiteral(resourceName: "Flix Icon"))
        iconProvider.backgroundView = UIView()
        iconProvider.backgroundView?.backgroundColor = UIColor.white
        iconProvider.selectedBackgroundView = UIView()
        iconProvider.selectedBackgroundView?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        iconProvider.itemSize = { [unowned self] in
            return CGSize(width: self.collectionView.bounds.width, height: 180)
        }
        iconProvider.contentView.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.centerXAnchor.constraint(equalTo: iconProvider.contentView.centerXAnchor).isActive = true
        iconImageView.centerYAnchor.constraint(equalTo: iconProvider.contentView.centerYAnchor).isActive = true
        
        iconProvider.tap
            .subscribe(onNext: {
                UIApplication.shared.open(URL(string: "https://github.com/DianQK/Flix")!, options: [:], completionHandler: nil)
            })
            .disposed(by: disposeBag)
        
        let textListProvider = TextListProvider(
            items: [
                Model(title: "Photos", desc: "", value: PhotoSettingsViewController.self),
                Model(title: "勿扰模式", desc: "", value: DoNotDisturbSettingsViewController.self),
                Model(title: "登录示例", desc: "", value: LoginViewController.self),
                Model(title: "GitHub Signup", desc: "", value: GitHubSignupViewController.self),
                Model(title: "嵌套表单", desc: "", value: NestFormViewController.self),
                Model(title: "删除示例", desc: "", value: DeleteItemViewController.self),
                Model(title: "控制中心", desc: "", value: ControlCenterCustomizeViewController.self)
            ]
        )
        textListProvider.tapped
            .subscribe(onNext: { [unowned self] (model) in
                self.show(model.value.init(), sender: nil)
            })
            .disposed(by: disposeBag)
        
        self.collectionView.flix.animatable.build([iconProvider, textListProvider])

    }

}
