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
    let activityIndicator = ActivityIndicator()
    var nickName = Variable("")
    var email = Variable("")
    var password = Variable("")
    var nextTaps = PublishSubject<Void>()
    
    // Output
    let nextEnabled: Driver<Bool>
    let nextFinished: Driver<SignUpResult>
    
    // Private
    fileprivate let provider: RxMoyaProvider<Buzzler>
    
    init(provider: RxMoyaProvider<Buzzler>) {
        self.provider = provider
        
        let nickNameObservable = nickName.asObservable()
        let emailObservable = email.asObservable()
        let passwordObservable = password.asObservable()
        
        nextEnabled = Observable.combineLatest(nickNameObservable, emailObservable, passwordObservable) { $0.characters.count > 2 && $1.characters.count > 2 && $2.characters.count > 2 }
            .asDriver(onErrorJustReturn: false)
        
        nextFinished = nextTaps
            .asObservable()
            .withLatestFrom(emailObservable)
            .flatMapLatest{(email) in
                provider.request(Buzzler.requestCode(receiver: email))
                    .retry(3)
                    .observeOn(MainScheduler.instance)
            }
            .mapJSON()
            .map { res in
                print("res: ", res)
                if let res = res as? String, res == "Success" {
                    return SignUpResult.ok
                }
                return SignUpResult.failed(message: "Error, something went wrong")
            }
            .asDriver(onErrorJustReturn: SignUpResult.failed(message: "Error, something went wrong"))
            .debug()
    }
    
    func requestCode(_ email: String) -> Observable<SignUpResult> {
        return provider.request(Buzzler.requestCode(receiver: email))
            .retry(3)
            .observeOn(MainScheduler.instance)
            .mapJSON()
            .map { res in
                if let res = res as? String, res == "Success" {
                    return SignUpResult.ok
                }
                return SignUpResult.failed(message: "Error, something went wrong")
            }
            .catchErrorJustReturn(SignUpResult.failed(message: "Error, something went wrong"))
    }
}
