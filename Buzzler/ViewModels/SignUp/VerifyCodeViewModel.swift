//
//  VerifyCodeViewModel.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 21..
//  Copyright © 2018년 Maru. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import RxOptional
import RxDataSources

private let disposeBag = DisposeBag()

public protocol VerifyCodeViewModelInputs {
    var code: PublishSubject<String?> { get }
    var nextTaps: PublishSubject<Void> { get }
    var resendTaps: PublishSubject<Void> { get }
}

public protocol VerifyCodeViewModelOutputs {
    var validatedCode: Driver<ValidationResult> { get }
    var enableNextButton: Driver<Bool> { get }
    var verifyCode: Driver<Bool> { get }
    var resendCode: Driver<Bool> { get }
    var isLoading: Driver<Bool> { get }
}

public protocol VerifyCodeViewModelType {
    var inputs: VerifyCodeViewModelInputs { get }
    var outputs: VerifyCodeViewModelOutputs { get }
}

class VerifyCodeViewModel: VerifyCodeViewModelInputs, VerifyCodeViewModelOutputs, VerifyCodeViewModelType {
    
    public var validatedCode: Driver<ValidationResult>
    public var enableNextButton: Driver<Bool>
    public var nextTaps: PublishSubject<Void>
    public var resendTaps: PublishSubject<Void>
    public var code: PublishSubject<String?>
    public var verifyCode: Driver<Bool>
    public var resendCode: Driver<Bool>
    public var isLoading: Driver<Bool>
    
    public var inputs: VerifyCodeViewModelInputs { return self }
    public var outputs: VerifyCodeViewModelOutputs { return self }
    
    // Private
    fileprivate let provider: RxMoyaProvider<Buzzler>
    var userInfo = UserInfo()
    
    init(provider: RxMoyaProvider<Buzzler>, userInfo: UserInfo) {
        self.provider = provider
        self.userInfo = userInfo
        
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
        
        let userInfoDriver = Driver.of(userInfo)
        let userData = Driver.combineLatest(self.code.asDriver(onErrorJustReturn: nil), userInfoDriver) { ($0, $1) }
        
        self.verifyCode = self.nextTaps
            .asDriver(onErrorJustReturn: ())
            .withLatestFrom(userData)
            .flatMapLatest { tuple in
                return provider.request(Buzzler.verifyCode(receiver: tuple.1.recevier!, verificationCode: tuple.0!))
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
                return provider.request(Buzzler.requestCode(receiver: tuple.1.recevier!))
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
