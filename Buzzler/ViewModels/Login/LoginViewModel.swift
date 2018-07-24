//
//  LoginViewModel.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 18..
//  Copyright © 2018년 Maru. All rights reserved.
//
import UIKit
import Foundation
import RxSwift
import RxCocoa
import Moya
import RxOptional
import RxDataSources

private let disposeBag = DisposeBag()

public protocol LoginViewModelInputs {
    var email:PublishSubject<String?> { get}
    var password:PublishSubject<String?> { get }
    var loginTaps:PublishSubject<Void> { get }
}

public protocol LoginViewModelOutputs {
    var validatedEmail: Driver<ValidationResult> { get }
    var validatedPassword: Driver<ValidationResult> { get }
    var enableLogin: Driver<Bool>{ get }
    var signedIn: Driver<Bool> { get }
    var isLoading: Driver<Bool> { get }
}

public protocol LoginViewModelType {
    var inputs: LoginViewModelInputs { get }
    var outputs: LoginViewModelOutputs { get }
}

class LoginViewModel: LoginViewModelType, LoginViewModelInputs, LoginViewModelOutputs {
    
    public var validatedEmail: Driver<ValidationResult>
    public var validatedPassword: Driver<ValidationResult>
    public var enableLogin: Driver<Bool>
    
    public var loginTaps: PublishSubject<Void>
    public var password: PublishSubject<String?>
    public var email: PublishSubject<String?>
    public var signedIn: Driver<Bool>
    public var isLoading: Driver<Bool>
    
    public var inputs: LoginViewModelInputs { return self }
    public var outputs: LoginViewModelOutputs { return self }
    
    // Private
    fileprivate let provider: RxMoyaProvider<Buzzler>
    
    public init(provider: RxMoyaProvider<Buzzler>) {
        self.provider = provider
        
        self.email = PublishSubject<String?>()
        self.password = PublishSubject<String?>()
        self.loginTaps = PublishSubject<Void>()
        
        let validationService = BuzzlerDefaultValidationService.sharedValidationService
        
        self.validatedEmail = self.email
            .asDriver(onErrorJustReturn: nil)
            .flatMapLatest { email in
                return validationService.validateUserId(email!)
                    .asDriver(onErrorJustReturn: .failed(message: "Error contacting server"))
        }
        
        self.validatedPassword = self.password
            .asDriver(onErrorJustReturn: nil)
            .map{ password in
                return validationService.validateTextString(password!)
        }
        
        self.enableLogin = Driver
            .combineLatest(validatedEmail, validatedPassword) { email, password in
                return email.isValid && password.isValid
        }
        
        let emailAndPassword = Driver.combineLatest(self.email.asDriver(onErrorJustReturn: nil),
                                                    self.password.asDriver(onErrorJustReturn: nil)) { ($0,$1)  }
        
        let isLoading = ActivityIndicator()
        self.isLoading = isLoading.asDriver()
        
        self.signedIn = self.loginTaps
            .asDriver(onErrorJustReturn:())
            .withLatestFrom(emailAndPassword)
            .flatMapLatest{ tuple in
                return provider.request(Buzzler.signIn(email: tuple.0!, password: tuple.1!))
                    .retry(3)
                    .observeOn(MainScheduler.instance)
                    .filterSuccessfulStatusCodes()
                    .mapJSON()
                    .flatMap({ token -> Single<Bool> in
                        print("Token", token)
                        if token is String {
                            // add userDefaults
                            var environment = Environment()
                            environment.token = token as? String
                            // save auto login info
                            if let autoLogin = environment.autoLogin, autoLogin {
                                environment.receiver = tuple.0!
                                environment.password = tuple.1!
                            }
                            
                            // save auto login info
                            if let saveEmail = environment.saveEmail, saveEmail {
                                environment.receiver = tuple.0!
                            }
                            
                            return Single.just(true)
                        } else {
                            return Single.just(false)
                        }
                    })
                    .trackActivity(isLoading)
                    .asDriver(onErrorJustReturn: false)
            }
            .flatMapLatest{ loginResult in
                return provider.request(Buzzler.getCategoriesByUser())
                    .retry(3)
                    .observeOn(MainScheduler.instance)
                    .filterSuccessfulStatusCodes()
                    .flatMap({ res -> Single<Bool> in
                        print("loginResult", loginResult)
                        print("res", res)
                        
                        // TODO: save categories
                        userCategories = try res.mapArray(UserCategory.self)
                        // create SideModel for SideSectionModel
                        sideCategories = userCategories.map{ category in
                            return SideModel.category(id: category.id, title: category.name)
                        }
                        sideCategories.append(SideModel.myPage(navTitle: "MyPageNavigationController"))
                        sideCategories.append(SideModel.settings(navTitle: "SettingsNavigationController"))
                        print(sideCategories)
                        // TODO: delete below
                        // save default categoryId
                        var environment = Environment()
                        environment.categoryId = 1
                        environment.categoryTitle = "Secret Lounge"
                        
                        return Single.just(loginResult)
                    })
                    .trackActivity(isLoading)
                    .asDriver(onErrorJustReturn: false)
        }
    }
}
