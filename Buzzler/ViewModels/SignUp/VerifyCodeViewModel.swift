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
    let nextFinished: Driver<SignUpResult>
    let nextExecuting: Driver<Bool>
    
    // Private
    fileprivate let provider: RxMoyaProvider<Buzzler>
    
    init(provider: RxMoyaProvider<Buzzler>) {
        self.provider = provider
        
        nextExecuting = Variable(false).asDriver().distinctUntilChanged()
    
        let codeObservable = code.asObservable()
        
        nextEnabled = codeObservable
            .map { text in
                return text.characters.count > 2 ? true : false
            }
            .asDriver(onErrorJustReturn: false)
        
        nextFinished = nextTaps
            .asObservable()
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
                return SignUpResult.ok
            }
            .asDriver(onErrorJustReturn: SignUpResult.failed(message: "Oops, something went wrong")).debug()
    }
    
    
}
