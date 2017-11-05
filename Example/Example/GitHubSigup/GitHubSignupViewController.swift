//
//  GitHubSignupViewController.swift
//  Example
//
//  Created by DianQK on 04/10/2017.
//  Copyright © 2017 DianQK. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Flix

class GitHubSignupViewController: TableViewController {
    
    let logoProvider: UniqueCustomTableViewSectionProvider = {
        let provider = UniqueCustomTableViewSectionProvider(tableElementKindSection: UITableElementKindSection.header)
        provider.backgroundView = UIView()
        provider.backgroundView?.backgroundColor = UIColor(named: "Cinder")
        provider.sectionHeight = { _ in return 180 }
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "GitHub Logo"))
        logoImageView.contentMode = .scaleAspectFit
        provider.contentView.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.centerXAnchor.constraint(equalTo: provider.contentView.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: provider.contentView.centerYAnchor).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        return provider
    }()
    
    let usernameProvider: UniqueTextFieldTableViewProvider = {
        let provider = UniqueTextFieldTableViewProvider()
        provider.textField.placeholder = "Username"
        provider.textField.keyboardType = .asciiCapable
        return provider
    }()
    let usernameValidationTableViewProvider = UniqueMessageTableViewProvider()
    
    let passwordProvider: UniqueTextFieldTableViewProvider = {
        let provider = UniqueTextFieldTableViewProvider()
        provider.textField.placeholder = "Password"
        provider.textField.isSecureTextEntry = true
        return provider
    }()
    let passwordValidationTableViewProvider = UniqueMessageTableViewProvider()
    
    let repeatedPasswordProvider: UniqueTextFieldTableViewProvider = {
        let provider = UniqueTextFieldTableViewProvider()
        provider.textField.placeholder = "Password Repeat"
        provider.textField.isSecureTextEntry = true
        return provider
    }()
    let repeatedPasswordValidationTableViewProvider = UniqueMessageTableViewProvider()
    
    let inputDesSectionProvider: UniqueCustomTableViewSectionProvider = {
        let provider = UniqueCustomTableViewSectionProvider(tableElementKindSection: .footer)
        provider.sectionHeight = { _ in return 35 }
        return provider
    }()

    let loginProvider: UniqueButtonTableViewProvider = {
        let provider = UniqueButtonTableViewProvider()
        provider.textLabel.textColor = UIColor.white
        provider.textLabel.text = "Sign up"
        return provider
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "GitHub Signup"
        
        let viewModel = GithubSignupViewModel1(
            input: (
                username: usernameProvider.textField.rx.text.orEmpty.asObservable(),
                password: passwordProvider.textField.rx.text.orEmpty.asObservable(),
                repeatedPassword: repeatedPasswordProvider.textField.rx.text.orEmpty.asObservable(),
                loginTaps: loginProvider.tap.asObservable()
            ),
            dependency: (
                API: GitHubDefaultAPI.sharedAPI,
                validationService: GitHubDefaultValidationService.sharedValidationService,
                wireframe: DefaultWireframe.shared
            )
        )
        
        viewModel.validatedUsername
            .bind(to: usernameValidationTableViewProvider.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.validatedPassword
            .bind(to: passwordValidationTableViewProvider.validationResult)
            .disposed(by: disposeBag)

        viewModel.validatedPasswordRepeated
            .bind(to: repeatedPasswordValidationTableViewProvider.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.signupEnabled
            .subscribe(onNext: { [unowned self] valid in
                self.loginProvider.isEnabled = valid
                self.loginProvider.selectionStyle.value = valid ? .default : .none
                self.loginProvider.backgroundView?.backgroundColor = valid ? UIColor(named: "Ufo Green")! : UIColor(named: "Ufo Green")?.withAlphaComponent(0.6)
                self.loginProvider.selectedBackgroundView?.backgroundColor = UIColor(named: "Eucalyptus")!
            })
            .disposed(by: disposeBag)
        
        viewModel.signedIn
            .subscribe(onNext: { signedIn in
                print("User signed in \(signedIn)")
            })
            .disposed(by: disposeBag)
        
        viewModel.signingIn
            .bind(to: loginProvider.activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)

        let inputSectionProviderBuilder = AnimatableTableViewSectionProvider(
            providers: [
                usernameProvider, usernameValidationTableViewProvider,
                passwordProvider, passwordValidationTableViewProvider,
                repeatedPasswordProvider, repeatedPasswordValidationTableViewProvider
            ],
            headerProvider: logoProvider,
            footerProvider: inputDesSectionProvider
        )
        let loginSectionProviderBuilder = AnimatableTableViewSectionProvider(providers: [loginProvider])
        
        self.tableView.flix.animatable.build([inputSectionProviderBuilder, loginSectionProviderBuilder])

    }
    
}
