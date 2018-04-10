//
//  LoginViewController.swift
//  Example
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
        
        title = "Login"
        
        usernameTextField.placeholder = "Username"
        usernameTextField.keyboardType = .asciiCapable
        
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        
        loginTextLabel.text = "Login"
        loginTextLabel.textAlignment = .center
        
        var section: [AnimatableTableViewSectionProvider] = []

        let usernameProvider = UniqueCustomTableViewProvider()
        usernameProvider.contentView.addSubview(usernameTextField)
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.leadingAnchor.constraint(equalTo: usernameProvider.contentView.leadingAnchor, constant: 15).isActive = true
        usernameTextField.topAnchor.constraint(equalTo: usernameProvider.contentView.topAnchor).isActive = true
        usernameTextField.trailingAnchor.constraint(equalTo: usernameProvider.contentView.trailingAnchor, constant: -15).isActive = true
        usernameTextField.bottomAnchor.constraint(equalTo: usernameProvider.contentView.bottomAnchor).isActive = true
        
        let passwordProvider = UniqueCustomTableViewProvider()
        passwordProvider.contentView.addSubview(passwordTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.leadingAnchor.constraint(equalTo: passwordProvider.contentView.leadingAnchor, constant: 15).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: passwordProvider.contentView.topAnchor).isActive = true
        passwordTextField.trailingAnchor.constraint(equalTo: passwordProvider.contentView.trailingAnchor, constant: -15).isActive = true
        passwordTextField.bottomAnchor.constraint(equalTo: passwordProvider.contentView.bottomAnchor).isActive = true
        
        let inputDesSectionFooterProvider = UniqueCustomTableViewSectionProvider(tableElementKindSection: .footer)
        inputDesSectionFooterProvider.sectionHeight = { _ in return 35 }
        
        let inputSectionProvider = AnimatableTableViewSectionProvider(
            providers: [usernameProvider, passwordProvider],
            footerProvider: inputDesSectionFooterProvider
        )
        section.append(inputSectionProvider)
        
        let loginProvider = UniqueCustomTableViewProvider()
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
                loginProvider.selectionStyle = isVerified ? .default : .none
            })
            .disposed(by: disposeBag)
        
        loginProvider.tap
            .withLatestFrom(isVerified).filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                let alert = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    self?.navigationController?.popViewController(animated: true)
                }))
                self?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        let loginSectionProvider = AnimatableTableViewSectionProvider(providers: [loginProvider])
        section.append(loginSectionProvider)
        
        self.tableView.flix.animatable.build(section)

    }
}
