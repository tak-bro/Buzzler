//
//  DetailPostViewModel.swift
//  Buzzler
//
//  Created by 진형탁 on 01/06/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx
import SwiftyJSON

public protocol DetailPostViewModelInputs {
    var loadDetailPostTrigger: PublishSubject<Void> { get }
    var inputtedComment: PublishSubject<String?> { get }
    var writeCommentTaps: PublishSubject<Void> { get }
    var deletePostTaps: PublishSubject<Void> { get }
    var likePostTaps: PublishSubject<Void> { get }
    var parentId: PublishSubject<String?> { get }
    var postId: PublishSubject<Int?> { get }
    func refresh()
}

public protocol DetailPostViewModelOutputs {
    var isLoading: Driver<Bool> { get }
    var elements: Variable<[MultipleSectionModel]> { get }
    var enableWriteButton: Driver<Bool> { get }
    var requestWriteComment: Driver<Bool> { get }
    var requestDeletePost: Driver<Bool> { get }
    var requestLikePost: Driver<Bool> { get }
    var validatedComment: Driver<ValidationResult> { get }
}

public protocol DetailPostViewModelType {
    var inputs: DetailPostViewModelInputs { get  }
    var outputs: DetailPostViewModelOutputs { get }
}

public class DetailPostViewModel: DetailPostViewModelInputs, DetailPostViewModelOutputs, DetailPostViewModelType {

    public var loadDetailPostTrigger: PublishSubject<Void>
    public var isLoading: Driver<Bool>
    public var elements: Variable<[MultipleSectionModel]>
    public var inputs: DetailPostViewModelInputs { return self}
    public var outputs: DetailPostViewModelOutputs { return self}
    
    // write comment action
    public var inputtedComment: PublishSubject<String?>
    public var enableWriteButton: Driver<Bool>
    public var validatedComment: Driver<ValidationResult>
    
    // http request
    public var writeCommentTaps: PublishSubject<Void>
    public var deletePostTaps: PublishSubject<Void>
    public var likePostTaps: PublishSubject<Void>
    public var requestWriteComment: Driver<Bool>
    public var requestDeletePost: Driver<Bool>
    public var requestLikePost: Driver<Bool>

    private let disposeBag = DisposeBag()
    private let error = PublishSubject<Swift.Error>()
    
    public func refresh() {
        self.loadDetailPostTrigger
            .onNext(())
    }
    
    public var parentId: PublishSubject<String?>
    public var postId: PublishSubject<Int?>
    
    init(id: Int) {
        self.loadDetailPostTrigger = PublishSubject<Void>()
        self.elements = Variable<[MultipleSectionModel]>([])
        let Loading = ActivityIndicator()
        self.isLoading = Loading.asDriver()
        
        self.inputtedComment = PublishSubject<String?>()
        self.writeCommentTaps = PublishSubject<Void>()
        self.deletePostTaps = PublishSubject<Void>()
        self.likePostTaps = PublishSubject<Void>()
        
        let validationService = BuzzlerDefaultValidationService.sharedValidationService
        
        self.validatedComment = self.inputtedComment
            .asDriver(onErrorJustReturn: nil)
            .map { comment in
                return validationService.validateTextString(comment!)
        }
        
        self.enableWriteButton = self.validatedComment.map { comment in
            return comment.isValid
        }
        
        self.parentId = PublishSubject<String?>()
        self.postId = PublishSubject<Int?>()
        
        let commentAndParentId = Driver.combineLatest(self.inputtedComment.asDriver(onErrorJustReturn: nil),
                                                      self.parentId.asDriver(onErrorJustReturn: nil)) { ($0, $1) }
        
        // write comment
        self.requestWriteComment = self.writeCommentTaps
            .asDriver(onErrorJustReturn:())
            .withLatestFrom(commentAndParentId)
            .flatMapLatest{ tuple in
                let environment = Environment()
                let categoryId = environment.categoryId
                
                return API.sharedAPI
                    .writeComment(categoryId: categoryId!, postId: id, parentId: tuple.1! == "" ? nil : tuple.1!, contents: tuple.0!)
                    .trackActivity(Loading)
                    .asDriver(onErrorJustReturn: false)
        }
        
        // delete Buzzler post
        self.requestDeletePost = self.deletePostTaps
            .asDriver(onErrorJustReturn:())
            .withLatestFrom(self.postId.asDriver(onErrorJustReturn: nil))
            .flatMapLatest{ postId in
                return API.sharedAPI
                    .deletePost(by: postId!)
                    .trackActivity(Loading)
                    .asDriver(onErrorJustReturn: false)
        }
        
        // like Buzzler post
        self.requestLikePost = self.likePostTaps
            .asDriver(onErrorJustReturn:())
            .withLatestFrom(self.postId.asDriver(onErrorJustReturn: nil))
            .flatMapLatest{ postId in
                let environment = Environment()
                let categoryId = environment.categoryId
                
                return API.sharedAPI
                    .likePost(categoryId: categoryId!, postId: postId!)
                    .trackActivity(Loading)
                    .asDriver(onErrorJustReturn: false)
        }
        
        // get detailPost data
        let loadRequest = self.isLoading.asObservable()
            .sample(self.loadDetailPostTrigger)
            .flatMap { isLoading -> Driver<[MultipleSectionModel]> in
                if isLoading {
                    return Driver.empty()
                } else {
                    self.elements.value.removeAll()
                    let environment = Environment()
                    let categoryId = environment.categoryId
                    return API.sharedAPI
                        .getDetailPost(categoryId: categoryId!, id: id)
                        .trackActivity(Loading)
                        .asDriver(onErrorJustReturn: [])
                }
        }
        
        let request = loadRequest
            .shareReplay(1)
        
        let response = request
            .flatMap { posts -> Observable<[MultipleSectionModel]> in
                request
                    .do(onError: { _error in
                        self.error.onNext(_error)
                    }).catchError({ error -> Observable<[MultipleSectionModel]> in
                        Observable.empty()
                    })
            }
            .shareReplay(1)
        
        Observable
            .combineLatest(request, response, elements.asObservable()) { request, response, elements in
                return response
            }
            .sample(response)
            .bind(to: elements)
            .disposed(by: disposeBag)
    }
    
}
