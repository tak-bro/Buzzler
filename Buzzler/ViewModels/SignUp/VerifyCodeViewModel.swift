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
    let activityIndicator = ActivityIndicator()
    var code = Variable("")
    var nextTaps = PublishSubject<Void>()
    
    // Output
    let nextEnabled: Driver<Bool>
    
    // Private
    fileprivate let provider: RxMoyaProvider<Buzzler>
    var userInfo = UserInfo()
    
    init(provider: RxMoyaProvider<Buzzler>, userInfo: UserInfo) {
        self.provider = provider
        self.userInfo = userInfo
        let codeObservable = code.asObservable()

        nextEnabled = codeObservable
            .map { text in
                return text.characters.count > 2 ? true : false
            }
            .asDriver(onErrorJustReturn: false)
    }
 
    func verifyCode(_ code: String) -> Observable<VerifyResult> {
        return provider.request(Buzzler.verifyCode(receiver: userInfo.recevier!, verificationCode: code))
            .retry(3)
            .observeOn(MainScheduler.instance)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .flatMap { res in
                return self.requestSignUp()
            }
            .catchErrorJustReturn(VerifyResult.failed(message: "Error, something went wrong"))
    }
    
    func requestSignUp() -> Observable<VerifyResult> {
        return provider.request(Buzzler.signUp(username: userInfo.nickName!,
                                               email: userInfo.recevier!,
                                               password: userInfo.password!))
            .retry(3)
            .observeOn(MainScheduler.instance)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .map { res in
                if let token = res as? String {
                    print("jwt token", token)
                }
                return VerifyResult.ok
            }
            .catchErrorJustReturn(VerifyResult.failed(message: "Error, something went wrong"))
    }
}
