//
//  APIWrapper.swift
//  Buzzler
//
//  Created by 진형탁 on 11/07/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

import Foundation

public protocol AwsAPI {
    func uploadS3(_ categoryId: Int, fileName: String, encodedImage: String) -> Observable<String>
}

public protocol BuzzlerAPI {
    func writePost(_ title: String, content: String, imageUrls: [String], categoryId: Int) -> Observable<Bool>
}


public class API: AwsAPI, BuzzlerAPI {
    
    static let sharedAPI = API()
    
    // Buzzler API
    public func writePost(_ title: String, content: String, imageUrls: [String], categoryId: Int) -> Observable<Bool> {
        return BuzzlerProvider.request(Buzzler.writePost(title: title, content: content,  imageUrls: imageUrls, categoryId: categoryId))
            .retry(3)
            .observeOn(MainScheduler.instance)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .flatMap({ res -> Single<Bool> in
                return Single.just(true)
            })
    }
    
    
    // AWS API
    public func uploadS3(_ categoryId: Int, fileName: String, encodedImage: String) -> Observable<String> {
        return AwsProvider.request(AWS.uploadS3(categoryId: categoryId, fileName: fileName, encodedImage: encodedImage))
            .retry(3)
            .observeOn(MainScheduler.instance)
            .filterSuccessfulStatusCodes()
            .flatMap({ res -> Single<String> in
                do {
                    let data = try res.mapObject(ImageReponse.self)
                    return Single.just(data.url)
                } catch {
                    return Single.just("")
                }
            })
    }
}
