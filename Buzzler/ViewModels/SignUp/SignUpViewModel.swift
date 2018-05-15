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
    var validatedEmail: Driver<ValidationResult> { get }
    var validatedPassword: Driver<ValidationResult> { get }
    var validatedConfirmPassword: Driver<ValidationResult> { get }
    var enableNextButton: Driver<Bool> { get }
    var requestCode: Driver<Bool> { get }
    var isLoading: Driver<Bool> { get }
}

public protocol SignUpViewModelType {
    var inputs: SignUpViewModelInputs { get }
    var outputs: SignUpViewModelOutputs { get }
}

class SignUpViewModel: SignUpViewModelInputs, SignUpViewModelOutputs, SignUpViewModelType {
    
    public var validatedEmail: Driver<ValidationResult>
    public var validatedPassword: Driver<ValidationResult>
    public var validatedConfirmPassword: Driver<ValidationResult>
    public var enableNextButton: Driver<Bool>
    
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
                return validationService.validatePassword(password!)
        }
        
        let pairPassword = Driver.combineLatest(self.password.asDriver(onErrorJustReturn: nil),
                                                self.confirmPassword.asDriver(onErrorJustReturn: nil)) { ($0, $1) }
        
        self.validatedConfirmPassword = pairPassword.asDriver()
            .map { password, confirmPassword in
                return validationService.validateConfirmPassword(password: password!, confirmPassword: confirmPassword!)
        }

        self.enableNextButton = Driver.combineLatest(
            validatedEmail,
            validatedPassword,
            validatedConfirmPassword) { email, password, confirmed in
                return email.isValid && password.isValid && confirmed.isValid
        }
        
        let emailAndPassword = Driver.combineLatest(self.email.asDriver(onErrorJustReturn: nil),
                                                    self.password.asDriver(onErrorJustReturn: nil)) { ($0, $1) }
        
        let isLoading = ActivityIndicator()
        self.isLoading = isLoading.asDriver()
        
        self.requestCode = self.nextTaps
            .asDriver(onErrorJustReturn:())
            .withLatestFrom(emailAndPassword)
            .flatMapLatest{ tuple in
                return provider.request(Buzzler.requestCode(receiver: tuple.0!))
                    .retry(3)
                    .observeOn(MainScheduler.instance)
                    .filterSuccessfulStatusCodes()
                    .mapJSON()
                    .flatMap({ res -> Single<Bool> in
                        print("res", res)
                        if let res = res as? String, res == "Success" {
                            return Single.just(true)
                        } else{
                            return Single.just(false)
                        }
                    })
                    .trackActivity(isLoading)
                    .asDriver(onErrorJustReturn: false)
        }
    }
    
    /*
    init(provider: RxMoyaProvider<Buzzler>) {
        
        self.provider = provider
        
        let nickNameObservable = nickName.asObservable()
        let emailObservable = email.asObservable()
        let passwordObservable = password.asObservable()
        
        nextEnabled = Observable.combineLatest(nickNameObservable, emailObservable, passwordObservable) { $0.characters.count > 2 && $1.characters.count > 2 && $2.characters.count > 2 }
            .asDriver(onErrorJustReturn: false)
    }
    
    func requestCode(_ email: String) -> Observable<SignUpResult> {
        return provider.request(Buzzler.requestCode(receiver: email))
            .retry(3)
            .observeOn(MainScheduler.instance)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .map { res in
                if let res = res as? String, res == "Success" {
                    return SignUpResult.ok
                }
                return SignUpResult.failed(message: "Error, something went wrong")
            }
            .catchErrorJustReturn(SignUpResult.failed(message: "Error, something went wrong"))
    }
 */
 
}
