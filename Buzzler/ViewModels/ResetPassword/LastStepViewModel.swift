//
//  LastStepViewModel.swift
//  Buzzler
//
//  Created by 진형탁 on 18/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa
import Moya
import RxOptional
import RxDataSources

private let disposeBag = DisposeBag()

public protocol LastStepViewModelInputs {
    var password: PublishSubject<String?> { get }
    var confirmPassword: PublishSubject<String?> { get }
    var nextTaps: PublishSubject<Void> { get }
}

public protocol LastStepViewModelOutputs {
    var validatedPassword: Driver<ValidationResult> { get }
    var validatedConfirmPassword: Driver<ValidationResult> { get }
    var enableNextButton: Driver<Bool> { get }
    var requestNewPassword: Driver<Bool> { get }
    var isLoading: Driver<Bool> { get }
    var setErrorMessage: Driver<String?> { get }
}

public protocol LastStepViewModelType {
    var inputs: LastStepViewModelInputs { get }
    var outputs: LastStepViewModelOutputs { get }
}

class LastStepViewModel: LastStepViewModelInputs, LastStepViewModelOutputs, LastStepViewModelType {
    
    public var validatedPassword: Driver<ValidationResult>
    public var validatedConfirmPassword: Driver<ValidationResult>
    public var enableNextButton: Driver<Bool>
    public var setErrorMessage: Driver<String?>
    
    public var nextTaps: PublishSubject<Void>
    public var password: PublishSubject<String?>
    public var confirmPassword: PublishSubject<String?>
    
    public var requestNewPassword: Driver<Bool>
    public var isLoading: Driver<Bool>
    
    public var inputs: LastStepViewModelInputs { return self }
    public var outputs: LastStepViewModelOutputs { return self }
    
    // Private
    fileprivate let provider: RxMoyaProvider<Buzzler>
    
    init(provider: RxMoyaProvider<Buzzler>) {
        self.provider = provider
        
        self.password = PublishSubject<String?>()
        self.confirmPassword = PublishSubject<String?>()
        self.nextTaps = PublishSubject<Void>()
        
        let validationService = BuzzlerDefaultValidationService.sharedValidationService
        
        let pairPassword = Driver.combineLatest(self.password.asDriver(onErrorJustReturn: nil),
                                                self.confirmPassword.asDriver(onErrorJustReturn: nil)) { ($0, $1) }
        
        self.validatedPassword = self.password.asDriver(onErrorJustReturn: nil)
            .map { password in
                return validationService.validateTextString(password!)
        }

        self.validatedConfirmPassword = pairPassword.asDriver()
            .map { password, confirmPassword in
                return validationService.validateConfirmPassword(password: password!, confirmPassword: confirmPassword!)
        }
        

        self.enableNextButton = self.validatedConfirmPassword.map { result in
            return result.isValid
        }
        
        self.setErrorMessage = self.validatedConfirmPassword.map { result in
            return result.isValid ? "" : "The passwords entered are not the same"
        }
        
        let isLoading = ActivityIndicator()
        self.isLoading = isLoading.asDriver()
        
        self.requestNewPassword = self.nextTaps
            .asDriver(onErrorJustReturn:())
            .withLatestFrom(self.password.asDriver(onErrorJustReturn: nil))
            .flatMapLatest{ email in
                return provider.request(Buzzler.requestCodeForNewPassword(receiver: email!))
                    .retry(3)
                    .observeOn(MainScheduler.instance)
                    .filterSuccessfulStatusCodes()
                    .mapJSON()
                    .flatMap({ res -> Single<Bool> in
                        print("requestCode for Reset Password: ", res)
                        if let res = res as? String, res == "OK" {
                            return Single.just(true)
                        } else{
                            return Single.just(false)
                        }
                    })
                    .trackActivity(isLoading)
                    .asDriver(onErrorJustReturn: false)
        }
    }
    
}
