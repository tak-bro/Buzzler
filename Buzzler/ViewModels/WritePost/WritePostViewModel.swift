//
//  PostViewModel.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 17..
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

public protocol WritePostViewModelInputs {
    var title: PublishSubject<String?> { get}
    var contents: PublishSubject<String?> { get }
    var postTaps: PublishSubject<Void> { get }
}

public protocol WritePostViewModelOutputs {
    var validatedTitle: Driver<ValidationResult> { get }
    var validatedContents: Driver<ValidationResult> { get }
    var enablePost: Driver<Bool>{ get }
    var posting: Driver<Bool> { get }
    var isLoading: Driver<Bool> { get }
}

public protocol WritePostViewModelType {
    var inputs: WritePostViewModelInputs { get }
    var outputs: WritePostViewModelOutputs { get }
}

class WritePostViewModel: WritePostViewModelInputs, WritePostViewModelOutputs, WritePostViewModelType {
    
    public var validatedTitle: Driver<ValidationResult>
    public var validatedContents: Driver<ValidationResult>
    public var enablePost: Driver<Bool>
    
    public var postTaps: PublishSubject<Void>
    public var title: PublishSubject<String?>
    public var contents: PublishSubject<String?>
    // public var imageUrls: PublishSubject<[String]?>
    public var posting: Driver<Bool>
    public var isLoading: Driver<Bool>
    
    public var inputs: WritePostViewModelInputs { return self }
    public var outputs: WritePostViewModelOutputs { return self }
    
    // Private
    fileprivate let provider: RxMoyaProvider<Buzzler>
    
    init(provider: RxMoyaProvider<Buzzler>) {
        self.provider = provider
        
        self.title = PublishSubject<String?>()
        self.contents = PublishSubject<String?>()
        self.postTaps = PublishSubject<Void>()
        
        let validationService = BuzzlerDefaultValidationService.sharedValidationService
        
        self.validatedTitle = self.title
            .asDriver(onErrorJustReturn: nil)
            .map { title in
                return validationService.validateTextString(title!)
        }
        
        self.validatedContents = self.contents
            .asDriver(onErrorJustReturn: nil)
            .map { contents in
                return validationService.validateTextString(contents!)
        }
        
        self.enablePost = Driver
            .combineLatest(validatedTitle, validatedContents) { title, contents in
                return title.isValid && contents.isValid
        }
        
        let titleAndContents = Driver.combineLatest(self.title.asDriver(onErrorJustReturn: nil),
                                                    self.contents.asDriver(onErrorJustReturn: nil)) { ($0,$1)  }
        
        let isLoading = ActivityIndicator()
        self.isLoading = isLoading.asDriver()
        
        self.posting = self.postTaps
            .asDriver(onErrorJustReturn:())
            .withLatestFrom(titleAndContents)
            .flatMapLatest{ tuple in
                let environment = Environment()
                return provider.request(Buzzler.writePost(title: tuple.0!, content: tuple.1!, imageUrls: ["test.png", "test.png"], categoryId: environment.categoryId!))
                    .retry(3)
                    .observeOn(MainScheduler.instance)
                    .filterSuccessfulStatusCodes()
                    .mapJSON()
                    .flatMap({ res -> Single<Bool> in
                        print("writePost res:", res)
                        return Single.just(true)
                    })
                    .trackActivity(isLoading)
                    .asDriver(onErrorJustReturn: false)
        }
        
    }
}
