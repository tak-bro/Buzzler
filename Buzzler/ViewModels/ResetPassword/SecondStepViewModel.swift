//
//  SecondStepViewModel.swift
//  Buzzler
//
//  Created by 진형탁 on 18/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import RxOptional
import RxDataSources

private let disposeBag = DisposeBag()

public protocol SecondStepViewModelInputs {
    var code: PublishSubject<String?> { get }
    var nextTaps: PublishSubject<Void> { get }
    var resendTaps: PublishSubject<Void> { get }
}

public protocol SecondStepViewModelOutputs {
    var validatedCode: Driver<ValidationResult> { get }
    var enableNextButton: Driver<Bool> { get }
    var verifyCode: Driver<Bool> { get }
    var resendCode: Driver<Bool> { get }
    var isLoading: Driver<Bool> { get }
}

public protocol SecondStepViewModelType {
    var inputs: SecondStepViewModelInputs { get }
    var outputs: SecondStepViewModelOutputs { get }
}

class SecondStepViewModel: SecondStepViewModelInputs, SecondStepViewModelOutputs, SecondStepViewModelType {

    public var validatedCode: Driver<ValidationResult>
    public var enableNextButton: Driver<Bool>
    public var nextTaps: PublishSubject<Void>
    public var resendTaps: PublishSubject<Void>
    public var code: PublishSubject<String?>
    public var verifyCode: Driver<Bool>
    public var resendCode: Driver<Bool>
    public var isLoading: Driver<Bool>
    
    public var inputs: SecondStepViewModelInputs { return self }
    public var outputs: SecondStepViewModelOutputs { return self }
    
    // Private
    fileprivate let provider: RxMoyaProvider<Buzzler>
    var userEmail = ""
    
    init(provider: RxMoyaProvider<Buzzler>, userEmail: String) {
        self.provider = provider
        self.userEmail = userEmail
        
        self.code = PublishSubject<String?>()
        self.nextTaps = PublishSubject<Void>()
        self.resendTaps = PublishSubject<Void>()
        
        let validationService = BuzzlerDefaultValidationService.sharedValidationService
        
        self.validatedCode = self.code.asDriver(onErrorJustReturn: nil)
            .flatMapLatest { code in
                return validationService.validateCode(code!)
                    .asDriver(onErrorJustReturn: .failed(message: "Error Verification Code"))
        }
        
        self.enableNextButton = self.validatedCode.map { code in
            return code.isValid
        }
        
        let isLoading = ActivityIndicator()
        self.isLoading = isLoading.asDriver()
        
        let userEmailDriver = Driver.of(userEmail)
        let userData = Driver.combineLatest(self.code.asDriver(onErrorJustReturn: nil), userEmailDriver) { ($0, $1) }
        
        self.verifyCode = self.nextTaps
            .asDriver(onErrorJustReturn: ())
            .withLatestFrom(userData)
            .flatMapLatest { tuple in
                return provider.request(Buzzler.verifyCodeForNewPassword(receiver: tuple.1, verificationCode: tuple.0!))
                    .retry(3)
                    .observeOn(MainScheduler.instance)
                    .filterSuccessfulStatusCodes()
                    .mapJSON()
                    .flatMap({ res -> Single<Bool> in
                        print("verifyCode res", res)
                        if let res = res as? String, res == "OK" {
                            return Single.just(true)
                        } else{
                            return Single.just(false)
                        }
                    })
                    .trackActivity(isLoading)
                    .asDriver(onErrorJustReturn: false)
        }
        
        self.resendCode = self.resendTaps
            .asDriver(onErrorJustReturn:())
            .withLatestFrom(userData)
            .flatMapLatest{ tuple in
                return provider.request(Buzzler.requestCodeForNewPassword(receiver: tuple.1))
                    .retry(3)
                    .observeOn(MainScheduler.instance)
                    .filterSuccessfulStatusCodes()
                    .mapJSON()
                    .flatMap({ res -> Single<Bool> in
                        print("resendCode res", res)
                        return Single.just(true)
                    })
                    .trackActivity(isLoading)
                    .asDriver(onErrorJustReturn: false)
        }
    }
}
