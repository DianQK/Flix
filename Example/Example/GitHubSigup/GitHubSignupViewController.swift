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


    typealias UniqueTextFieldVerifiableTableViewProvider = ValidationTableViewProvider<UniqueTextFieldTableViewProvider>

    let usernameProvider: UniqueTextFieldVerifiableTableViewProvider = {
        let provider = UniqueTextFieldTableViewProvider()
        provider.textField.placeholder = "Username"
        provider.textField.keyboardType = .asciiCapable
        return UniqueTextFieldVerifiableTableViewProvider(valueProvider: provider)
    }()
    
    let passwordProvider: UniqueTextFieldVerifiableTableViewProvider = {
        let provider = UniqueTextFieldTableViewProvider()
        provider.textField.placeholder = "Password"
        provider.textField.isSecureTextEntry = true
        return UniqueTextFieldVerifiableTableViewProvider(valueProvider: provider)
    }()
    
    let repeatedPasswordProvider: UniqueTextFieldVerifiableTableViewProvider = {
        let provider = UniqueTextFieldTableViewProvider()
        provider.textField.placeholder = "Password Repeat"
        provider.textField.isSecureTextEntry = true
        return UniqueTextFieldVerifiableTableViewProvider(valueProvider: provider)
    }()
    
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
        
        title = "Join GitHub"
        
        let viewModel = GithubSignupViewModel1(
            input: (
                username: usernameProvider.valueProvider.textField.rx.text.orEmpty.asObservable().distinctUntilChanged(),
                password: passwordProvider.valueProvider.textField.rx.text.orEmpty.asObservable(),
                repeatedPassword: repeatedPasswordProvider.valueProvider.textField.rx.text.orEmpty.asObservable(),
                loginTaps: loginProvider.event.selectedEvent.asObservable()
            ),
            dependency: (
                API: GitHubDefaultAPI.sharedAPI,
                validationService: GitHubDefaultValidationService.sharedValidationService,
                wireframe: DefaultWireframe.shared
            )
        )
        
        viewModel.validatedUsername
            .bind(to: usernameProvider.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.validatedPassword
            .bind(to: passwordProvider.validationResult)
            .disposed(by: disposeBag)

        viewModel.validatedPasswordRepeated
            .bind(to: repeatedPasswordProvider.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.signUpEnabled
            .subscribe(onNext: { [unowned self] valid in
                self.loginProvider.isEnabled = valid
                self.loginProvider.selectionStyle = valid ? .default : .none
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
            providers: [usernameProvider, passwordProvider, repeatedPasswordProvider],
            headerProvider: logoProvider,
            footerProvider: inputDesSectionProvider
        )
        let loginSectionProviderBuilder = AnimatableTableViewSectionProvider(providers: [loginProvider])
        
        self.tableView.flix.animatable.build([inputSectionProviderBuilder, loginSectionProviderBuilder])

    }
    
}
