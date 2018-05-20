//
//  HomeViewModel.swift
//  Buzzler
//
//  Created by Tak on 2018/04/08.
//  Copyright © 2018年 Tak. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import NSObject_Rx

final class HomeViewModel: NSObject, ViewModelType {

    typealias Input  = HomeInput
    typealias Output = HomeOutput

    // Inputs
    struct HomeInput {
        let category = Variable<Int>(1)
    }

    // Output
    struct HomeOutput {
        let section: Driver<[BuzzlerSection]>
        let refreshCommand = PublishSubject<Int>()
        let refreshTrigger = PublishSubject<Void>()

        init(buzzlerSection: Driver<[BuzzlerSection]>) {
            section = buzzlerSection
        }
    }

    private let _posts = Variable<[BuzzlerPost]>([])

    /// Tansform Action for DataBinding
    func transform(input: HomeViewModel.Input) -> HomeViewModel.Output {
        let section = _posts.asObservable().map({ (posts) -> [BuzzlerSection] in
            return [BuzzlerSection(items: posts)]
        })
        .asDriver(onErrorJustReturn: [])
        
        let output = Output(buzzlerSection: section)
        output.refreshCommand
            .flatMapLatest { BuzzlerProvider.request(Buzzler.getPost(category: $0)) }
            .subscribe({ [weak self] (event) in
                output.refreshTrigger.onNext()
                switch event {
                case let .next(response):
                    do {
                        let data = try response.mapArray(BuzzlerPost.self)
                        self?._posts.value = data
                    } catch {
                        self?._posts.value = []
                    }
                    break
                case let .error(error):
                    output.refreshTrigger.onError(error)
                    break
                default:
                    break
                }
            })
            .disposed(by: rx.disposeBag)

        return output
    }

    override init() {
        super.init()
    }
}
