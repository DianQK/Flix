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
        
        typealias UIViewControllerCreater = () -> UIViewController
        typealias Model = TextListProviderModel<UIViewControllerCreater>
        
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
                Model(title: "Settings", desc: "", value: { return SettingsViewController() }),
                Model(title: "All Events", desc: "", value: { return EventListViewController() }),
                Model(title: "Do Not Disturb", desc: "", value: { return DoNotDisturbSettingsViewController() }),
                Model(title: "Login", desc: "", value: { return LoginViewController() }),
                Model(title: "GitHub Signup", desc: "", value: { return GitHubSignupViewController() }),
                Model(title: "Nest Form", desc: "", value: { return NestFormViewController() }),
                Model(title: "Delete", desc: "", value: { return DeleteItemViewController() }),
                Model(title: "Control Center", desc: "", value: { return ControlCenterCustomizeViewController() }),
                Model(title: "Storyboard", desc: "", value: { return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StoryboardViewController") })
            ]
        )
        textListProvider.tapped
            .subscribe(onNext: { [unowned self] (model) in
                self.show(model.value(), sender: nil)
            })
            .disposed(by: disposeBag)
        
        self.collectionView.flix.animatable.build([iconProvider, textListProvider])

    }

}
