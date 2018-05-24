//
//  FirstStepViewModel.swift
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

public protocol FisrtStepViewModelInputs {
    var email: PublishSubject<String?> { get }
    var nextTaps: PublishSubject<Void> { get }
}

public protocol FirstStepViewModelOutputs {
    var validatedEmail: Driver<ValidationResult> { get }
    var enableNextButton: Driver<Bool> { get }
    var requestCode: Driver<Bool> { get }
    var isLoading: Driver<Bool> { get }
    var setErrorMessage: Driver<String?> { get }
}

public protocol FirstStepViewModelType {
    var inputs: FisrtStepViewModelInputs { get }
    var outputs: FirstStepViewModelOutputs { get }
}

class FirstStepViewModel: FisrtStepViewModelInputs, FirstStepViewModelOutputs, FirstStepViewModelType {

    public var validatedEmail: Driver<ValidationResult>
    public var enableNextButton: Driver<Bool>
    public var setErrorMessage: Driver<String?>
    
    public var nextTaps: PublishSubject<Void>
    public var email: PublishSubject<String?>

    public var requestCode: Driver<Bool>
    public var isLoading: Driver<Bool>
    
    public var inputs: FisrtStepViewModelInputs { return self }
    public var outputs: FirstStepViewModelOutputs { return self }
    
    // Private
    fileprivate let provider: RxMoyaProvider<Buzzler>
    
    init(provider: RxMoyaProvider<Buzzler>) {
        self.provider = provider
        
        self.email = PublishSubject<String?>()
        self.nextTaps = PublishSubject<Void>()
        
        let validationService = BuzzlerDefaultValidationService.sharedValidationService
        
        self.validatedEmail = self.email.asDriver(onErrorJustReturn: nil)
            .flatMapLatest { email in
                return validationService.validateEmail(email!)
                    .asDriver(onErrorJustReturn: .failed(message: "Error email"))
        }
        
        self.enableNextButton = self.validatedEmail.map { email in
            return email.isValid
        }

        self.setErrorMessage = self.validatedEmail.map { email in
            return email.isValid ? "" : "This email address is not valid"
        }

        let isLoading = ActivityIndicator()
        self.isLoading = isLoading.asDriver()
        
        self.requestCode = self.nextTaps
            .asDriver(onErrorJustReturn:())
            .withLatestFrom(self.email.asDriver(onErrorJustReturn: nil))
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
