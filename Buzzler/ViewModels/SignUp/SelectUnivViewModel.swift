//
//  SelectUnivViewModel.swift
//  Buzzler
//
//  Created by 진형탁 on 21/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import RxOptional
import RxDataSources

private let disposeBag = DisposeBag()

public protocol SelectUnivViewModelInputs {
    var univ: PublishSubject<String?> { get }
    var nextTaps: PublishSubject<Void> { get }
}

public protocol SelectUnivViewModelOutputs {
    var validatedUniv: Driver<ValidationResult> { get }
    var enableNextButton: Driver<Bool> { get }
    var getMajorList: Driver<Any> { get }
    var isLoading: Driver<Bool> { get }
}

public protocol SelectUnivViewModelType {
    var inputs: SelectUnivViewModelInputs { get }
    var outputs: SelectUnivViewModelOutputs { get }
}

class SelectUnivViewModel: SelectUnivViewModelInputs, SelectUnivViewModelOutputs, SelectUnivViewModelType {
    
    public var validatedUniv: Driver<ValidationResult>
    public var enableNextButton: Driver<Bool>
    
    public var nextTaps: PublishSubject<Void>
    public var univ: PublishSubject<String?>
    public var getMajorList: Driver<Any>
    public var isLoading: Driver<Bool>
    
    public var inputs: SelectUnivViewModelInputs { return self }
    public var outputs: SelectUnivViewModelOutputs { return self }
    
    // Private
    fileprivate let provider: RxMoyaProvider<Buzzler>
    var userInfo = UserInfo()
    
    init(provider: RxMoyaProvider<Buzzler>, userInfo: UserInfo) {
        self.provider = provider
        self.userInfo = userInfo
        
        self.univ = PublishSubject<String?>()
        self.nextTaps = PublishSubject<Void>()
        
        let validationService = BuzzlerDefaultValidationService.sharedValidationService
        
        self.validatedUniv = self.univ
            .asDriver(onErrorJustReturn: nil)
            .map { univ in
                return validationService.validateTextString(univ!)
        }
        
        self.enableNextButton = self.validatedUniv.map { univ in
            return univ.isValid
        }

        let isLoading = ActivityIndicator()
        self.isLoading = isLoading.asDriver()
        
        self.getMajorList = self.nextTaps
            .asDriver(onErrorJustReturn: ())
            .withLatestFrom(self.univ.asDriver(onErrorJustReturn: nil))
            .flatMapLatest { univ in
                return provider.request(Buzzler.getMajor(email: userInfo.recevier!))
                    .retry(3)
                    .observeOn(MainScheduler.instance)
                    .filterSuccessfulStatusCodes()
                    .mapJSON()
                    .flatMap({ res -> Single<Any> in
                        print("getMajorList res", res)
                        return Single.just(res)
                    })
                    .trackActivity(isLoading)
                    .asDriver(onErrorJustReturn: false)
        }
    }
}
