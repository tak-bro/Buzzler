//
//  SelectMajorViewModel.swift
//  Buzzler
//
//  Created by 진형탁 on 15/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import RxOptional
import RxDataSources

private let disposeBag = DisposeBag()

public protocol SelectMajorViewModelInputs {
    var univ: PublishSubject<String?> { get }
    var major: PublishSubject<String?> { get }
    var nextTaps: PublishSubject<Void> { get }
}

public protocol SelectMajorViewModelOutputs {
    var validatedUniv: Driver<ValidationResult> { get }
    var validatedMajor: Driver<ValidationResult> { get }
    var enableNextButton: Driver<Bool> { get }
    var signedUp: Driver<Bool> { get }
    var isLoading: Driver<Bool> { get }
}

public protocol SelectMajorViewModelType {
    var inputs: SelectMajorViewModelInputs { get }
    var outputs: SelectMajorViewModelOutputs { get }
}

class SelectMajorViewModel: SelectMajorViewModelInputs, SelectMajorViewModelOutputs, SelectMajorViewModelType {
    
    public var validatedUniv: Driver<ValidationResult>
    public var validatedMajor: Driver<ValidationResult>
    public var enableNextButton: Driver<Bool>
    
    public var nextTaps: PublishSubject<Void>
    public var univ: PublishSubject<String?>
    public var major: PublishSubject<String?>
    public var signedUp: Driver<Bool>
    public var isLoading: Driver<Bool>
    
    public var inputs: SelectMajorViewModelInputs { return self }
    public var outputs: SelectMajorViewModelOutputs { return self }
    
    // Private
    fileprivate let provider: RxMoyaProvider<Buzzler>
    var userInfo = UserInfo()
    
    init(provider: RxMoyaProvider<Buzzler>, userInfo: UserInfo) {
        self.provider = provider
        self.userInfo = userInfo
        
        self.univ = PublishSubject<String?>()
        self.major = PublishSubject<String?>()
        self.nextTaps = PublishSubject<Void>()

        let validationService = BuzzlerDefaultValidationService.sharedValidationService
        
        self.validatedUniv = self.univ
            .asDriver(onErrorJustReturn: nil)
            .map { univ in
                return validationService.validateTextString(univ!)
        }
        
        self.validatedMajor = self.major
            .asDriver(onErrorJustReturn: nil)
            .map { major in
                return validationService.validateTextString(major!)
        }
        
        self.enableNextButton = Driver.combineLatest(
            validatedUniv,
            validatedMajor) { univ, major in
                return univ.isValid && major.isValid
        }
        
        let isLoading = ActivityIndicator()
        self.isLoading = isLoading.asDriver()
        
        let univAndMajar = Driver.combineLatest(self.univ.asDriver(onErrorJustReturn: nil),
                                            self.major.asDriver(onErrorJustReturn: nil)) { ($0, $1) }
        
        self.signedUp = self.nextTaps
            .asDriver(onErrorJustReturn: ())
            .withLatestFrom(univAndMajar)
            .flatMapLatest { tuple in
                let environment = Environment()
                return provider.request(Buzzler.signUp(username: environment.nickName!,
                                                       email: environment.receiver!,
                                                       password: environment.password!,
                                                       categoryAuth: [environment.univ!, environment.major!]))
                    .retry(3)
                    .observeOn(MainScheduler.instance)
                    .filterSuccessfulStatusCodes()
                    .mapJSON()
                    .flatMap({ res -> Single<Bool> in
                        print("signUp res", res)
                        if res is String {
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
