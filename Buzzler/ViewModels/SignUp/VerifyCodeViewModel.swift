//
//  VerifyCodeViewModel.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 21..
//  Copyright © 2018년 Maru. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

class VerifyCodeViewModel {
    
    // Input
    var code = Variable("")
    var nextTaps = PublishSubject<Void>()
    
    // Output
    let nextEnabled: Driver<Bool>
    let nextFinished: Driver<VerifyResult>
    var nextExecuting: Driver<Bool>
    
    // Private
    fileprivate let provider: RxMoyaProvider<Buzzler>
    fileprivate let userInfo = UserInfo()
    
    init(provider: RxMoyaProvider<Buzzler>, userInfo: UserInfo) {
        self.provider = provider
        
        nextExecuting = Variable(false).asDriver().distinctUntilChanged()
    
        let codeObservable = code.asObservable()
        let verifying = ActivityIndicator()
        self.nextExecuting = verifying.asDriver()
        
        nextEnabled = codeObservable
            .map { text in
                return text.characters.count > 2 ? true : false
            }
            .asDriver(onErrorJustReturn: false)
        
        nextFinished = nextTaps
            .asObservable()
            .withLatestFrom(codeObservable)
            .flatMapLatest{ (code) in
                provider.request(Buzzler.verifyCode(receiver: userInfo.recevier!, verificationCode: code))
                    .trackActivity(verifying)
                    .retry(3)
                    .observeOn(MainScheduler.instance)
            }
            .filterSuccessfulStatusCodes()
            .flatMap{ _ in
                    provider.request(Buzzler.signUp(username: userInfo.nickName!,
                                                email: userInfo.recevier!,
                                                password: userInfo.password!))
                    .trackActivity(verifying)
                    .retry(3)
                    .observeOn(MainScheduler.instance)
            }
            .mapJSON()
            .map{ res in
                print("111res: ", res)
                if let res = res as? String, res == "Success" {
                    return VerifyResult.ok
                }
                return VerifyResult.failed(message: "Error, something went wrong")
            }
            .asDriver(onErrorJustReturn: VerifyResult.failed(message: "Error, something went wrong"))
            .debug()

    }
}
