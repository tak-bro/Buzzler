//
//  HomeViewModel.swift
//  Buzzler
//
//  Created by Tak on 2018/04/08.
//  Copyright © 2018年 Tak. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx
import SwiftyJSON

public protocol HomeViewModelInputs {
    var loadPageTrigger: PublishSubject<Void> { get }
    var loadNextPageTrigger: PublishSubject<Void> { get }
    func refresh()
    func tapped(indexRow: Int)
    func category(category: Int)
}

public protocol HomeViewModelOutputs {
    var isLoading: Driver<Bool> { get }
    var moreLoading: Driver<Bool> { get }
    var elements: Variable<[BuzzlerPost]> { get }
    // TODO: add push
    // var selectedViewModel: Driver<RepoViewModel> { get }
}

public protocol HomeViewModelType {
    var inputs: HomeViewModelInputs { get  }
    var outputs: HomeViewModelOutputs { get }
}

public class HomeViewModel: HomeViewModelType, HomeViewModelInputs, HomeViewModelOutputs {
    
    // public var selectedViewModel: Driver<RepoViewModel>
    public var loadPageTrigger:PublishSubject<Void>
    public var loadNextPageTrigger:PublishSubject<Void>
    public var moreLoading: Driver<Bool>
    public var isLoading: Driver<Bool>
    public var elements:Variable<[BuzzlerPost]>
    public var inputs: HomeViewModelInputs { return self}
    public var outputs: HomeViewModelOutputs { return self}
    
    private let disposeBag = DisposeBag()
    private var pageIndex: Int = 1
    private let error = PublishSubject<Swift.Error>()
    private var category = 0
    
    init() {
        // self.selectedViewModel = Driver.empty()
        self.loadPageTrigger = PublishSubject<Void>()
        self.loadNextPageTrigger = PublishSubject<Void>()
        self.elements = Variable<[BuzzlerPost]>([])
        let Loading = ActivityIndicator()
        self.isLoading = Loading.asDriver()
        // TOOO: add pagination
        let moreLoading = ActivityIndicator()
        self.moreLoading = moreLoading.asDriver()
        
        // first time load data
        let loadRequest = self.isLoading.asObservable()
            .sample(self.loadPageTrigger)
            .flatMap { isLoading -> Driver<[BuzzlerPost]> in
                if isLoading {
                    return Driver.empty()
                } else {
                    self.pageIndex = 1
                    self.elements.value.removeAll()
                    return BuzzlerProvider.request(Buzzler.getPost(category: self.category))
                        .retry(3)
                        .observeOn(MainScheduler.instance)
                        .flatMap({ res -> Single<[BuzzlerPost]> in
                            do {
                                let data = try res.mapArray(BuzzlerPost.self)
                                return Single.just(data)
                            } catch {
                                return Single.just([])
                            }
                        })
                        .trackActivity(Loading)
                        .asDriver(onErrorJustReturn: [])
                }
        }
        
        //get more data by page
        let nextRequest = self.moreLoading.asObservable()
            .sample(self.loadNextPageTrigger)
            .flatMap { isLoading -> Driver<[BuzzlerPost]> in
                if isLoading {
                    return Driver.empty()
                } else {
                    self.pageIndex = self.pageIndex + 1
                    return BuzzlerProvider.request(Buzzler.getPost(category: self.category))
                        .retry(3)
                        .observeOn(MainScheduler.instance)
                        .filterSuccessfulStatusCodes()
                        .flatMap({ res -> Single<[BuzzlerPost]> in
                            do {
                                let data = try res.mapArray(BuzzlerPost.self)
                                return Single.just(data)
                            } catch {
                                return Single.just([])
                            }
                        })
                        .trackActivity(Loading)
                        .asDriver(onErrorJustReturn: [])
                }
        }
        
        let request = Observable.of(loadRequest, nextRequest)
            .merge()
            .shareReplay(1)
        
        let response = request
            .flatMap { posts -> Observable<[BuzzlerPost]> in
                request
                    .do(onError: { _error in
                        self.error.onNext(_error)
                    }).catchError({ error -> Observable<[BuzzlerPost]> in
                        Observable.empty()
                    })
            }
            .shareReplay(1)
        
        //combine data when get more data by paging
        Observable
            .combineLatest(request, response, elements.asObservable()) { request, response, elements in
                return self.pageIndex == 1 ? response : elements + response
            }
            .sample(response)
            .bind(to: elements)
            .disposed(by: disposeBag)
        
        /* TODO: add selected item
         //binding selected item
         self.selectedViewModel = self.repository.asDriver().filterNil().flatMapLatest{ repo -> Driver<RepoViewModel> in
         return Driver.just(RepoViewModel(repo: repo))
         }
         */
    }
    
    public func refresh() {
        self.loadPageTrigger
            .onNext(())
    }
    
    let post = Variable<BuzzlerPost?>(nil)
    public func tapped(indexRow: Int) {
        let post = self.elements.value[indexRow]
        self.post.value = post
    }
    
    public func category(category: Int) {
        self.category = category
    }
}
