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
import SwiftyJSON

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
    // set univ text
    var setUniv: Driver<String?> { get }
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
    
    public var setUniv: Driver<String?>
    
    // Private
    fileprivate let provider: RxMoyaProvider<Buzzler>
    var userInfo = UserInfo()
    
    init(provider: RxMoyaProvider<Buzzler>, userInfo: UserInfo) {
        self.provider = provider
        self.userInfo = userInfo
        
        self.univ = PublishSubject<String?>()
        self.nextTaps = PublishSubject<Void>()
        
        let validationService = BuzzlerDefaultValidationService.sharedValidationService
        
        let isLoading = ActivityIndicator()
        self.isLoading = isLoading.asDriver()
        
        self.setUniv = provider.request(Buzzler.getUniv(email: userInfo.recevier!))
            .retry(3)
            .observeOn(MainScheduler.instance)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .map { JSON($0) }
            .map { json in
                return json[0]["name"].stringValue
            }
            .asDriver(onErrorJustReturn: "Error")
        
        self.validatedUniv = self.setUniv
            .map { univ in
                return validationService.validateTextString(univ!)
        }
        
        self.enableNextButton = self.validatedUniv.map { univ in
            return univ.isValid
        }
        
        self.getMajorList = self.nextTaps
            .asDriver(onErrorJustReturn: ())
            .flatMapLatest { _ in
                return provider.request(Buzzler.getMajor())
                    .retry(3)
                    .observeOn(MainScheduler.instance)
                    .filterSuccessfulStatusCodes()
                    .mapJSON()
                    .map { JSON($0) }
                    .flatMap({ res -> Single<Any> in
                        print("getMajorList res", res)
                        var majors: [MajorInfo] = []
                        
                        for subJson in res.arrayValue {
                            print("Test")
                            if let categoryDepth = subJson["categoryDepth"].int, let id = subJson["id"].int, let name = subJson["name"].string {
                                print("Tes1232312t")
                                majors.append(MajorInfo(categoryDepth: categoryDepth, id: id, name: name))
                            }
                        }
                        
                        return Single.just(majors)
                    })
                    .trackActivity(isLoading)
                    .asDriver(onErrorJustReturn: false)
        }
    }
}
