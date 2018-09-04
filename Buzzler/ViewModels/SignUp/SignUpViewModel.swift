//
//  SignUpViewModel.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 21..
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

public protocol SignUpViewModelInputs {
    var nickName: PublishSubject<String?> { get }
    var email: PublishSubject<String?> { get }
    var password: PublishSubject<String?> { get }
    var confirmPassword: PublishSubject<String?> { get }
    var nextTaps: PublishSubject<Void> { get }
}

public protocol SignUpViewModelOutputs {
    var validatedNickName: Driver<ValidationResult> { get }
    var validatedEmail: Driver<ValidationResult> { get }
    var validatedPassword: Driver<ValidationResult> { get }
    var validatedConfirmPassword: Driver<ValidationResult> { get }
    var enableNextButton: Driver<Bool> { get }
    var requestCode: Driver<Bool> { get }
    var isLoading: Driver<Bool> { get }
    var setErrorMessage: Driver<String?> { get }
}

public protocol SignUpViewModelType {
    var inputs: SignUpViewModelInputs { get }
    var outputs: SignUpViewModelOutputs { get }
}

class SignUpViewModel: SignUpViewModelInputs, SignUpViewModelOutputs, SignUpViewModelType {
    
    public var validatedNickName: Driver<ValidationResult>
    public var validatedEmail: Driver<ValidationResult>
    public var validatedPassword: Driver<ValidationResult>
    public var validatedConfirmPassword: Driver<ValidationResult>
    
    public var enableNextButton: Driver<Bool>
    public var setErrorMessage: Driver<String?>
    
    public var nextTaps: PublishSubject<Void>
    public var nickName: PublishSubject<String?>
    public var email: PublishSubject<String?>
    public var password: PublishSubject<String?>
    public var confirmPassword: PublishSubject<String?>
    
    public var requestCode: Driver<Bool>
    public var isLoading: Driver<Bool>
    
    public var inputs: SignUpViewModelInputs { return self }
    public var outputs: SignUpViewModelOutputs { return self }
    
    // Private
    fileprivate let provider: RxMoyaProvider<Buzzler>
    
    init(provider: RxMoyaProvider<Buzzler>) {
        self.provider = provider
        
        self.nickName = PublishSubject<String?>()
        self.email = PublishSubject<String?>()
        self.password = PublishSubject<String?>()
        self.confirmPassword = PublishSubject<String?>()
        self.nextTaps = PublishSubject<Void>()
        
        let validationService = BuzzlerDefaultValidationService.sharedValidationService
        
        self.validatedEmail = self.email.asDriver(onErrorJustReturn: nil)
            .flatMapLatest { email in
                return validationService.validateEmail(email!)
                    .asDriver(onErrorJustReturn: .failed(message: "Error email"))
        }
        
        self.validatedPassword = self.password.asDriver(onErrorJustReturn: nil)
            .map { password in
                return validationService.validateTextString(password!)
        }
        
        self.validatedNickName = self.nickName.asDriver(onErrorJustReturn: nil)
            .map { nickName in
                return validationService.validateTextString(nickName!)
        }
        
        let pairPassword = Driver.combineLatest(self.password.asDriver(onErrorJustReturn: nil),
                                                self.confirmPassword.asDriver(onErrorJustReturn: nil)) { ($0, $1) }
        
        self.validatedConfirmPassword = pairPassword.asDriver()
            .map { password, confirmPassword in
                return validationService.validateConfirmPassword(password: password!, confirmPassword: confirmPassword!)
        }
        
        self.enableNextButton = Driver.combineLatest(
            validatedNickName,
            validatedEmail,
            validatedPassword,
            validatedConfirmPassword) { nickName, email, password, confirmed in
                return nickName.isValid && email.isValid && password.isValid && confirmed.isValid
        }
        
        self.setErrorMessage = Driver.combineLatest(validatedNickName, validatedEmail, validatedConfirmPassword) { nickName, email, confirmPassword in
            if email.isValid && confirmPassword.isValid && nickName.isValid {
                return ""
            }
            // return error message
            if !email.isValid {
                return "This email address is not valid"
            } else if !confirmPassword.isValid {
                return "The passwords entered are not the same"
            } else {
                return "Make sure you enter your information correctly"
            }
        }
        
        let emailAndPasswordAndNickName = Driver.combineLatest(self.email.asDriver(onErrorJustReturn: nil),
                                                    self.password.asDriver(onErrorJustReturn: nil),
                                                    self.nickName.asDriver(onErrorJustReturn: nil)) { ($0, $1, $2) }
        
        let isLoading = ActivityIndicator()
        self.isLoading = isLoading.asDriver()
        
        self.requestCode = self.nextTaps
            .asDriver(onErrorJustReturn:())
            .withLatestFrom(emailAndPasswordAndNickName)
            .flatMapLatest{ data in
                // save to environment
                var environment = Environment()
                environment.receiver = data.0
                environment.password = data.1
                environment.nickName = data.2
                
                return API.sharedAPI
                    .requestCode(receiver: environment.receiver!)
                    .trackActivity(isLoading)
                    .asDriver(onErrorJustReturn: false)
        }
    }
    
}
