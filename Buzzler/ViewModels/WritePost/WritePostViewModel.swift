//
//  PostViewModel.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 17..
//  Copyright © 2018년 Maru. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

class WritePostViewModel {
    
    // Input
    var title = Variable<String>("")
    var content = Variable<String>("")
    var imageUrls = Variable<[String]>([""])
    var postTaps = PublishSubject<Void>()
    
    // Output
    let postFinished: Driver<LoginResult>
    let postExecuting: Driver<Bool>
    
    // Private
    fileprivate let provider: RxMoyaProvider<Buzzler>
    
    init(provider: RxMoyaProvider<Buzzler>) {
        self.provider = provider
        
        postExecuting = Variable(false).asDriver().distinctUntilChanged()
        
        let titleObservable = title.asObservable()
        let contentObservable = content.asObservable()
        let imageUrlsObservable = imageUrls.asObservable()
        
        let combineBody = Observable.combineLatest(titleObservable, contentObservable, imageUrlsObservable){ ($0, $1, $2) }
        
        postFinished = postTaps
            .asObservable()
            .withLatestFrom(combineBody)
            .flatMapLatest{(title, content, imageUrls) in
                provider.request(Buzzler.writePost(title: title, content: content, imageUrls: imageUrls))
                    .retry(3)
                    .observeOn(MainScheduler.instance)
            }
            .checkIfRateLimitExceeded()
            .mapJSON()
            .do(onNext: { json in
                // var appToken = Token()
                //                appToken.token = json["token"] as? String
                print(json)
            })
            .map { json in
                //                if let message = json["message"] as? String {
                //                    return LoginResult.failed(message: message)
                //                } else {
                //                    return LoginResult.ok
                //                }
                return LoginResult.ok
            }
            .asDriver(onErrorJustReturn: LoginResult.failed(message: "Oops, something went wrong")).debug()
    }
    
}
