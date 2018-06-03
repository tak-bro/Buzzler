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
    var parentId: PublishSubject<String?> { get }
    func refresh()
}

public protocol DetailPostViewModelOutputs {
    var isLoading: Driver<Bool> { get }
    var elements: Variable<[MultipleSectionModel]> { get }
    var enableWriteButton: Driver<Bool> { get }
    var requestWriteComment: Driver<Bool> { get }
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
    public var writeCommentTaps: PublishSubject<Void>
    public var requestWriteComment: Driver<Bool>
    public var validatedComment: Driver<ValidationResult>
    
    private let disposeBag = DisposeBag()
    private let error = PublishSubject<Swift.Error>()
    
    public func refresh() {
        self.loadDetailPostTrigger
            .onNext(())
    }
    
    public var parentId: PublishSubject<String?>
    
    init(id: Int) {
        self.loadDetailPostTrigger = PublishSubject<Void>()
        self.elements = Variable<[MultipleSectionModel]>([])
        let Loading = ActivityIndicator()
        self.isLoading = Loading.asDriver()
        
        self.inputtedComment = PublishSubject<String?>()
        self.writeCommentTaps = PublishSubject<Void>()
        
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
        
        let commentAndParentId = Driver.combineLatest(self.inputtedComment.asDriver(onErrorJustReturn: nil),
                                                      self.parentId.asDriver(onErrorJustReturn: nil)) { ($0, $1) }
        
        // write comment
        self.requestWriteComment = self.writeCommentTaps
            .asDriver(onErrorJustReturn:())
            .withLatestFrom(commentAndParentId)
            .flatMapLatest{ tuple in
                return BuzzlerProvider.request(Buzzler.writeComment(postId: id, parentId: tuple.1! == "" ? nil : tuple.1!, content: tuple.0!))
                    .retry(3)
                    .observeOn(MainScheduler.instance)
                    .filterSuccessfulStatusCodes()
                    .mapJSON()
                    .flatMap({ res -> Single<Bool> in
                        print("res: ", res)
                        return Single.just(true)
                    })
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
                    return BuzzlerProvider.request(Buzzler.getDetailPost(id: id))
                        .retry(3)
                        .observeOn(MainScheduler.instance)
                        .flatMap({ res -> Single<[MultipleSectionModel]> in
                            do {
                                let data = try res.mapObject(DetailBuzzlerPost.self)
                                
                                // convert response to BuzzlerPost model
                                let defaultPost = BuzzlerPost(id: data.id, title: data.title, content: data.content,
                                                              imageUrls: data.imageUrls, likeCount: data.likeCount, createdAt: data.createdAt,
                                                              authorId: data.authorId)
                                
                                // convert comments to CommentSection
                                let comments = data.comments
                                    .sorted(by: BuzzlerComment.customCompare) // sort as comment order with parentId
                                    .map({ (comment: BuzzlerComment) -> MultipleSectionModel in
                                        if let _ = comment.parentId {
                                            return .ReCommentSection(title: "ReCommentSection", items: [.ReCommentItem(item: comment)])
                                        } else {
                                            return .CommentSection(title: "CommentSection", items: [.CommentItem(item: comment)])
                                        }
                                    })
                                
                                // init default MutlipleSection
                                var sections: [MultipleSectionModel] = [
                                    .PostSection(title: "PostSection", items: [.PostItem(item: defaultPost)]),
                                    // .CommentSection(title: "CommentSection", items: [.CommentItem(item: comment[0])])
                                    // .CommentSection(title: "CommentSection", items: [.CommentItem(item: comment[1])])
                                    // .ReCommentSection(title: "CommentSection", items: [.CommentItem(item: comment[2])])
                                    // .CommentSection(title: "CommentSection", items: [.CommentItem(item: comment[3])])
                                    // ...
                                ]
                                
                                // create datasource for Table
                                sections.append(contentsOf: comments)
                                return Single.just(sections)
                            } catch {
                                return Single.just([])
                            }
                        })
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
