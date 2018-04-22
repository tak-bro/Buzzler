//
//  HomeViewModel.swift
//  Gank
//
//  Created by Maru on 2016/12/7.
//  Copyright © 2016年 Maru. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import NSObject_Rx

typealias GankType = GankAPI.GankCategory

final class HomeViewModel: NSObject, ViewModelType {


    typealias Input  = HomeInput
    typealias Output = HomeOutput

    // Inputs
    struct HomeInput {
        let category = Variable<Int>(0)
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

    // Public  Stuff
    var itemURLs = Variable<[URL]>([])
    // Private Stuff
    fileprivate let _posts = Variable<[BuzzlerPost]>([])

    /// Tansform Action for DataBinding
    func transform(input: HomeViewModel.Input) -> HomeViewModel.Output {
        let section = _posts.asObservable().map({ (posts) -> [BuzzlerSection] in
            return [BuzzlerSection(items: posts)]
        })
        .asDriver(onErrorJustReturn: [])
        
        let output = Output(buzzlerSection: section)
        output.refreshCommand
            .flatMapLatest { _ in BuzzlerProvider.request(Buzzler.getPost).retry(3) }
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
        _posts.asObservable().map { (posts) -> [URL] in
            return posts.map({ (post) -> URL in
                return URL(string: post.url) ?? URL(string: "http://audiga-admin.failnicely.com:8081")!
            })
        }.subscribe(onNext: { [weak self] (urls) in
            self?.itemURLs.value = urls
        }, onError: nil, onCompleted: nil, onDisposed: nil)
        .disposed(by: rx.disposeBag)
    }
}
