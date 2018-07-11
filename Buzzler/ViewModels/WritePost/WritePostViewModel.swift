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
import Photos
import DKImagePickerController

private let disposeBag = DisposeBag()

public protocol WritePostViewModelInputs {
    var title: PublishSubject<String?> { get}
    var contents: PublishSubject<String?> { get }
    var images: PublishSubject<[DKAsset]?> { get }
    var postTaps: PublishSubject<Void> { get }
}

public protocol WritePostViewModelOutputs {
    var validatedTitle: Driver<ValidationResult> { get }
    var validatedContents: Driver<ValidationResult> { get }
    var encodedImages: Driver<[PostImage]>{ get }
    var enablePost: Driver<Bool>{ get }
    var posting: Driver<Bool> { get }
    var isLoading: Driver<Bool> { get }
}

public protocol WritePostViewModelType {
    var inputs: WritePostViewModelInputs { get }
    var outputs: WritePostViewModelOutputs { get }
}

class WritePostViewModel: WritePostViewModelInputs, WritePostViewModelOutputs, WritePostViewModelType {
    
    public var encodedImages: Driver<[PostImage]>
    public var validatedTitle: Driver<ValidationResult>
    public var validatedContents: Driver<ValidationResult>
    public var enablePost: Driver<Bool>
    
    public var images: PublishSubject<[DKAsset]?>
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
    fileprivate let awsProvider: RxMoyaProvider<AWS>
    
    init(provider: RxMoyaProvider<Buzzler>, awsProvider: RxMoyaProvider<AWS>) {
        self.provider = provider
        self.awsProvider = awsProvider
        
        self.images = PublishSubject<[DKAsset]?>()
        self.title = PublishSubject<String?>()
        self.contents = PublishSubject<String?>()
        self.postTaps = PublishSubject<Void>()
        
        let validationService = BuzzlerDefaultValidationService.sharedValidationService
        
        self.encodedImages = self.images
            .asDriver(onErrorJustReturn: nil)
            .map { images in
                guard let images = images else { return [PostImage]() }
                return validationService.encodedImages(images)
        }
        
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

        let isLoading = ActivityIndicator()
        self.isLoading = isLoading.asDriver()
        
        let titleAndContentsAndImage = Driver.combineLatest(self.title.asDriver(onErrorJustReturn: nil),
                                                            self.contents.asDriver(onErrorJustReturn: nil),
                                                            self.encodedImages) { ($0,$1,$2)  }
        
        self.posting = self.postTaps
            .asDriver(onErrorJustReturn:())
            .withLatestFrom(titleAndContentsAndImage)
            .flatMapLatest { items in
                let title = items.0
                let contents = items.1
                let encoded = items.2
                
                let environment = Environment()
                var categoryId = environment.categoryId
                categoryId = 0
                
                let uploadRequest = encoded.map { image in
                    return API.sharedAwsAPI.uploadS3(categoryId!, fileName: image.fileName, encodedImage: image.encodedImgData)
                        .trackActivity(isLoading)
                }

                return Observable.from(uploadRequest)
                    .merge()
                    .shareReplay(1)
                    .toArray()
                    .flatMapLatest { items in
                        return provider.request(Buzzler.writePost(title: title!, content: contents!,  imageUrls: items, categoryId: environment.categoryId!))
                            .retry(3)
                            .observeOn(MainScheduler.instance)
                            .filterSuccessfulStatusCodes()
                            .mapJSON()
                            .flatMap({ res -> Single<Bool> in
                                print("writePost res:", res)
                                return Single.just(true)
                            })
                            .trackActivity(isLoading)
                    }
                    .asDriver(onErrorJustReturn: false)
        }
    }
}
