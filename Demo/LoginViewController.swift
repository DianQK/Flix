//
//  LoginViewController.swift
//  Demo
//
//  Created by DianQK on 04/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

class LoginViewController: TableViewController {

    let usernameTextField = UITextField()
    let passwordTextField = UITextField()
    
    let loginTextLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "登录"
        
        usernameTextField.placeholder = "用户名"
        usernameTextField.keyboardType = .asciiCapable
        
        passwordTextField.placeholder = "密码"
        passwordTextField.isSecureTextEntry = true
        
        loginTextLabel.text = "登录"
        loginTextLabel.textAlignment = .center
        
        var section: [SectionProviderTableViewBuilder] = []

        let usernameProvider = UniqueCustomTableViewProvider(identity: "username")
        usernameProvider.contentView.addSubview(usernameTextField)
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.leadingAnchor.constraint(equalTo: usernameProvider.contentView.leadingAnchor, constant: 15).isActive = true
        usernameTextField.topAnchor.constraint(equalTo: usernameProvider.contentView.topAnchor).isActive = true
        usernameTextField.trailingAnchor.constraint(equalTo: usernameProvider.contentView.trailingAnchor, constant: -15).isActive = true
        usernameTextField.bottomAnchor.constraint(equalTo: usernameProvider.contentView.bottomAnchor).isActive = true
        
        let passwordProvider = UniqueCustomTableViewProvider(identity: "password")
        passwordProvider.contentView.addSubview(passwordTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.leadingAnchor.constraint(equalTo: passwordProvider.contentView.leadingAnchor, constant: 15).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: passwordProvider.contentView.topAnchor).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: passwordProvider.contentView.trailingAnchor, constant: -15).isActive = true
        passwordTextField.bottomAnchor.constraint(equalTo: passwordProvider.contentView.bottomAnchor).isActive = true
        
        let inputDesSectionProvider = UniqueCustomTableViewSectionProvider(
            identity: "inputDesSectionProvider",
            tableElementKindSection: UITableElementKindSection.footer
        )
        inputDesSectionProvider.sectionHeight = { return 35 }
        
        let inputSectionProviderBuilder = SectionProviderTableViewBuilder(
            identity: "inputSectionProviderBuilder",
            providers: [usernameProvider, passwordProvider],
            footerProvider: inputDesSectionProvider
        )
        section.append(inputSectionProviderBuilder)
        
        let loginProvider = UniqueCustomTableViewProvider(identity: "login")
        loginProvider.contentView.addSubview(loginTextLabel)
        loginTextLabel.translatesAutoresizingMaskIntoConstraints = false
        loginTextLabel.leadingAnchor.constraint(equalTo: loginProvider.contentView.leadingAnchor).isActive = true
        loginTextLabel.topAnchor.constraint(equalTo: loginProvider.contentView.topAnchor).isActive = true
        loginTextLabel.trailingAnchor.constraint(equalTo: loginProvider.contentView.trailingAnchor).isActive = true
        loginTextLabel.bottomAnchor.constraint(equalTo: loginProvider.contentView.bottomAnchor).isActive = true
        
        let isVerified: Observable<Bool> = Observable
            .combineLatest(
                self.usernameTextField.rx.text.orEmpty.map { !$0.isEmpty },
                self.passwordTextField.rx.text.orEmpty.map { !$0.isEmpty }
            ) { $0 && $1 }
            .share(replay: 1, scope: .forever)
        
        isVerified
            .subscribe(onNext: { [weak self] (isVerified) in
                self?.loginTextLabel.textColor = isVerified ? UIColor.red : UIColor.lightGray
                loginProvider.selectionStyle.value = isVerified ? .default : .none
            })
            .disposed(by: disposeBag)
        
        loginProvider.tap
            .withLatestFrom(isVerified).filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                let alert = UIAlertController(title: "登录成功", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "好", style: .default, handler: { (_) in
                    self?.navigationController?.popViewController(animated: true)
                }))
                self?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        let loginSectionProviderBuilder = SectionProviderTableViewBuilder(
            identity: "loginSectionProviderBuilder",
            providers: [loginProvider]
        )
        section.append(loginSectionProviderBuilder)
        
        self.tableViewService = AnimatableTableViewService(
            tableView: tableView,
            sectionProviderBuilders: section
        )
        
    }
}
