//
//  SignUpViewModel.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 21..
//  Copyright © 2018년 Maru. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

class SignUpViewModel {
    
    // Input
    var nickName = Variable("")
    var email = Variable("")
    var password = Variable("")
    var nextTaps = PublishSubject<Void>()
    
    // Output
    let nextEnabled: Driver<Bool>
    let nextFinished: Driver<LoginResult>
    let nextExecuting: Driver<Bool>
    
    // Private
    fileprivate let provider: RxMoyaProvider<Buzzler>
    
    init(provider: RxMoyaProvider<Buzzler>) {
        self.provider = provider
        
        nextExecuting = Variable(false).asDriver().distinctUntilChanged()
        
        let nickNameObservable = nickName.asObservable()
        let emailObservable = email.asObservable()
        let passwordObservable = password.asObservable()
        
        nextEnabled = Observable.combineLatest(nickNameObservable, emailObservable, passwordObservable) { $0.characters.count > 4 && $1.characters.count > 5 && $2.characters.count > 5 }
            .asDriver(onErrorJustReturn: false)
        
        let combineData = Observable.combineLatest(nickNameObservable, emailObservable, passwordObservable){ ($0, $1, $2) }
        
        nextFinished = nextTaps
            .asObservable()
            .withLatestFrom(combineData)
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
