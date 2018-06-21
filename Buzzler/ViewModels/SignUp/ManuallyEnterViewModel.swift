//
//  ManuallyEnterViewModel.swift
//  Buzzler
//
//  Created by 진형탁 on 21/06/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya
import RxOptional
import RxDataSources

private let disposeBag = DisposeBag()

public protocol ManuallyEnterViewModelInputs {
    var college: PublishSubject<String?> { get }
    var major: PublishSubject<String?> { get }
    var nextTaps: PublishSubject<Void> { get }
}

public protocol ManuallyEnterViewModelOutputs {
    var validatedCollege: Driver<ValidationResult> { get }
    var validatedMajor: Driver<ValidationResult> { get }
    var enableNextButton: Driver<Bool> { get }
    var createCategory: Driver<Bool> { get }
    var isLoading: Driver<Bool> { get }
    var setErrorMessage: Driver<String?> { get }
}

public protocol ManuallyEnterViewModelType {
    var inputs: ManuallyEnterViewModelInputs { get }
    var outputs: ManuallyEnterViewModelOutputs { get }
}


class ManuallyEnterViewModel: ManuallyEnterViewModelInputs, ManuallyEnterViewModelOutputs, ManuallyEnterViewModelType {
    
    // output
    public var validatedCollege: Driver<ValidationResult>
    public var validatedMajor: Driver<ValidationResult>
    public var enableNextButton: Driver<Bool>
    public var setErrorMessage: Driver<String?>
    public var isLoading: Driver<Bool>
    public var createCategory: Driver<Bool>
    
    // input
    public var college: PublishSubject<String?>
    public var major: PublishSubject<String?>
    public var nextTaps: PublishSubject<Void>
    
    public var inputs: ManuallyEnterViewModelInputs { return self }
    public var outputs: ManuallyEnterViewModelOutputs { return self }
    
    // Private
    fileprivate let provider: RxMoyaProvider<Buzzler>
    
    init(provider: RxMoyaProvider<Buzzler>) {
        self.provider = provider
        
        self.college = PublishSubject<String?>()
        self.major = PublishSubject<String?>()
        self.nextTaps = PublishSubject<Void>()
        
        let validationService = BuzzlerDefaultValidationService.sharedValidationService
        
        self.validatedCollege = self.college.asDriver(onErrorJustReturn: nil)
            .map { college in
                return validationService.validateTextString(college!)
        }
        
        self.validatedMajor = self.major.asDriver(onErrorJustReturn: nil)
            .map { major in
                return validationService.validateTextString(major!)
        }
        
        self.enableNextButton = Driver.combineLatest(
            validatedCollege,
            validatedMajor) { college, major in
                return college.isValid && major.isValid
        }
        
        self.setErrorMessage = Driver.combineLatest(validatedCollege, validatedMajor) { college, major in
            if college.isValid && major.isValid {
                return ""
            } else {
                return "Too short data!"
            }
        }
        
        let collegeAndMajor = Driver.combineLatest(self.college.asDriver(onErrorJustReturn: nil),
                                                   self.major.asDriver(onErrorJustReturn: nil)) { ($0, $1) }
        
        let isLoading = ActivityIndicator()
        self.isLoading = isLoading.asDriver()
        
        self.createCategory = self.nextTaps
            .asDriver(onErrorJustReturn:())
            .withLatestFrom(collegeAndMajor)
            .flatMapLatest{ data in
                return Observable.merge(
                    provider.request(Buzzler.createCategory(depth: 1, name: "네이버", baseUrl: "naver.com"))
                        .retry(3)
                        .observeOn(MainScheduler.instance)
                        .filterSuccessfulStatusCodes()
                        .mapJSON()
                        .flatMap({ res -> Single<Bool> in
                            print("createCategory res", res)
                            return Single.just(true)
                        })
                        .trackActivity(isLoading),
                    provider.request(Buzzler.createCategory(depth: 2, name: "컴퓨터공학", baseUrl: ""))
                        .retry(3)
                        .observeOn(MainScheduler.instance)
                        .filterSuccessfulStatusCodes()
                        .mapJSON()
                        .flatMap({ res -> Single<Bool> in
                            print("createCategory res", res)
                            return Single.just(true)
                        })
                        .trackActivity(isLoading)
                )
                .asDriver(onErrorJustReturn: false)
        }
    }
}
