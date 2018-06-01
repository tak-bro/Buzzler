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
    func refresh()
}

public protocol DetailPostViewModelOutputs {
    var isLoading: Driver<Bool> { get }
    var elements: Variable<[MultipleSectionModel]> { get }
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
    
    private let disposeBag = DisposeBag()
    private let error = PublishSubject<Swift.Error>()
    
    public func refresh() {
        self.loadDetailPostTrigger
            .onNext(())
    }
    
    init(id: Int) {
        self.loadDetailPostTrigger = PublishSubject<Void>()
        self.elements = Variable<[MultipleSectionModel]>([])
        let Loading = ActivityIndicator()
        self.isLoading = Loading.asDriver()
        
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
                                let comments = data.comments.map({ (comment: BuzzlerComment) -> MultipleSectionModel in
                                    return .CommentSection(title: "CommentSection", items: [.CommentItem(item: comment)])
                                })
                                // init default MutlipleSection
                                var sections: [MultipleSectionModel] = [
                                    .PostSection(title: "PostSection", items: [.PostItem(item: defaultPost)]),
                                    // .CommentSection(title: "CommentSection", items: [.CommentItem(item: comment[0])])
                                    // .CommentSection(title: "CommentSection", items: [.CommentItem(item: comment[1])])
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
