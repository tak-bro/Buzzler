//
//  MyPageViewModel.swift
//  Buzzler
//
//  Created by 진형탁 on 09/08/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx
import SwiftyJSON

public protocol MyPageViewModelInputs {
    var loadPageTrigger: PublishSubject<Void> { get }
    var loadNextPageTrigger: PublishSubject<Void> { get }
    func refresh()
    func tapped(indexRow: Int)
    func category(category: Int)
}

public protocol MyPageViewModelOutputs {
    var isLoading: Driver<Bool> { get }
    var moreLoading: Driver<Bool> { get }
    var elements: Variable<[BuzzlerPost]> { get }
    var selectedViewModel: Driver<DetailPostViewModel> { get }
}

public protocol MyPageViewModelType {
    var inputs: MyPageViewModelInputs { get  }
    var outputs: MyPageViewModelOutputs { get }
}

public class MyPageViewModel: MyPageViewModelType, MyPageViewModelInputs, MyPageViewModelOutputs {
    
    public var selectedViewModel: Driver<DetailPostViewModel>
    public var loadPageTrigger:PublishSubject<Void>
    public var loadNextPageTrigger:PublishSubject<Void>
    public var moreLoading: Driver<Bool>
    public var isLoading: Driver<Bool>
    public var elements:Variable<[BuzzlerPost]>
    public var inputs: MyPageViewModelInputs { return self}
    public var outputs: MyPageViewModelOutputs { return self}
    
    private let disposeBag = DisposeBag()
    private var pageIndex: Int = 1
    private let error = PublishSubject<Swift.Error>()
    private var category = 0
    
    init() {
        self.selectedViewModel = Driver.empty()
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
                    return API.sharedAPI
                        .getPost(self.category)
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
                    return API.sharedAPI
                        .getPost(self.category)
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
        
        //binding selected item
        self.selectedViewModel = self.post.asDriver()
            .filterNil()
            .flatMapLatest{ post -> Driver<DetailPostViewModel> in
                return Driver.just(DetailPostViewModel(selectedPost: post))
        }
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
