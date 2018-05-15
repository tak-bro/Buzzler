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
    var email:PublishSubject<String?>{ get}
    var password:PublishSubject<String?>{ get }
    var loginTaps:PublishSubject<Void>{ get }
}

public protocol LoginViewModelOutputs {
    var validatedEmail: Driver<ValidationResult> { get }
    var validatedPassword: Driver<ValidationResult> { get }
    var enableLogin: Driver<Bool>{ get }
    var signedIn: Driver<Bool> { get }
    var isLoading: Driver<Bool> { get }
}

public protocol LoginViewModelType {
    var inputs: LoginViewModelInputs { get  }
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
    
    public var inputs: LoginViewModelInputs { return self}
    public var outputs: LoginViewModelOutputs { return self}
    
    // Private
    fileprivate let provider: RxMoyaProvider<Buzzler>
    
    public init(provider: RxMoyaProvider<Buzzler>) {
        self.provider = provider
        
        self.email = PublishSubject<String?>()
        self.password = PublishSubject<String?>()
        self.loginTaps = PublishSubject<Void>()
        
        let validationService = BuzzlerDefaultValidationService.sharedValidationService
        
        self.validatedEmail = self.email.asDriver(onErrorJustReturn: nil).flatMapLatest{ email in
            return validationService.validateUserId(email!)
                .asDriver(onErrorJustReturn: .failed(message: "Error contacting server"))
        }
        
        self.validatedPassword = self.password.asDriver(onErrorJustReturn: nil).map{ password in
            return validationService.validatePassword(password!)
        }
        
        self.enableLogin = Driver.combineLatest(
            validatedEmail,
            validatedPassword) { email, password in
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
                        print("token", token)
                        if token == nil {
                            return Single.just(false)
                        } else{
                            // var environment = Environment()
                            // environment.token = author.token
                            return Single.just(true)
                        }
                    })
                    .trackActivity(isLoading)
                    .asDriver(onErrorJustReturn: false)
        }
    }
}

