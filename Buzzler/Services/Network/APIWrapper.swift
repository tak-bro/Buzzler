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
    func getPost(_ category: Int) -> Observable<[BuzzlerPost]>
    func getDetailPost(categoryId: Int, id: Int) -> Observable<[MultipleSectionModel]>
    func writePost(_ title: String, contents: String, imageUrls: [String], categoryId: Int) -> Observable<WritePostResponse>
    func writeComment(categoryId: Int, postId: Int, parentId: String?, contents: String) -> Observable<Bool>
    func requestCode(receiver: String) -> Observable<Bool>
    func signIn(email: String, password: String) -> Observable<LoginResponse>
    func getUserInfo(loginResult: LoginResponse) -> Observable<LoginResponse>
    func likePost(categoryId: Int, postId: Int) -> Observable<LikePostResponse>
//    func requestCodeForNewPassword(receiver: String) -> Observable<RequestCodePassword>
//    func verifyCodeForNewPassword(receiver: String, verificationCode: String) -> Observable<VerifyCodeResponse>
}

public class API: AwsAPI, BuzzlerAPI {
    
    static let sharedAPI = API()
    
    // Buzzler API
    
    public func likePost(categoryId: Int, postId: Int) -> Observable<LikePostResponse> {
        return BuzzlerProvider.request(Buzzler.likePost(categoryId: categoryId, postId: postId))
            .retry(3)
            .filterSuccessfulStatusCodes()
            .observeOn(MainScheduler.instance)
            .flatMap({ res -> Single<LikePostResponse> in
                let responseData = try res.mapObject(LikePostResponse.self)
                return Single.just(responseData)
            })
    }
    
    public func deletePost(by postId: Int) -> Observable<Bool> {
        return BuzzlerProvider.request(Buzzler.deletePost(postId: postId))
            .retry(3)
            .filterSuccessfulStatusCodes()
            .observeOn(MainScheduler.instance)
            .flatMap({ res -> Single<Bool> in
                do {
                    print(res)
                    return Single.just(true)
                } catch {
                    return Single.just(false)
                }
            })
    }
    
    public func getPost(_ category: Int) -> Observable<[BuzzlerPost]> {
        return BuzzlerProvider.request(Buzzler.getPost(category: category))
            .retry(3)
            .filterSuccessfulStatusCodes()
            .observeOn(MainScheduler.instance)
            .flatMap({ res -> Single<[BuzzlerPost]> in
                do {
                    let responseData = try res.mapObject(BuzzlerPostResponse.self)
                    if let _ = responseData.error {
                        return Single.just([])
                    }
                    
                    let data = responseData.result
                    return Single.just(data)
                } catch {
                    return Single.just([])
                }
            })
    }
    
    public func getDetailPost(categoryId: Int, id: Int) -> Observable<[MultipleSectionModel]> {
        return BuzzlerProvider.request(Buzzler.getDetailPost(categoryId: categoryId, id: id))
            .retry(3)
            .filterSuccessfulStatusCodes()
            .observeOn(MainScheduler.instance)
            .flatMap({ res -> Single<[MultipleSectionModel]> in
                do {
                    let responseData = try res.mapObject(DetailPostResponse.self)
                    if let _ = responseData.error {
                        return Single.just([])
                    }
                    
                    if let data = responseData.result {
                        // convert response to BuzzlerPost model
                        let defaultPost = BuzzlerPost(id: data.id, title: data.title, contents: data.contents,
                                                      commentCount: data.commentCount, imageUrls: data.imageUrls, likeCount: data.likeCount,
                                                      createdAt: data.createdAt, author: data.author)
                        
                        // join comments with child
                        let commentsData = data.commentList
                            .map { item -> [BuzzlerComment] in
                                var commentsWithChild = [BuzzlerComment]()
                                commentsWithChild.insertFirst(item)
                                
                                if item.childrenComment.count > 0 {
                                    // add parentId for children comment
                                    let children = item.childrenComment.map { recommentItem -> (BuzzlerComment) in
                                        // create new recomment data with parentId
                                        let recomment = BuzzlerComment(id: recommentItem.id, author: recommentItem.author, postId: recommentItem.postId,
                                                                       parentId: item.id, contents: recommentItem.contents, createdAt: recommentItem.createdAt,
                                                                       likeCount: item.likeCount, childrenComment: item.childrenComment)
                                        return recomment
                                    }
                                    
                                    commentsWithChild = commentsWithChild + children
                                }
                                return commentsWithChild
                            }
                            .flatMap{ $0 }
                        
                        // convert comments to CommentSection
                        var comments = commentsData
                            .map({ (comment: BuzzlerComment) -> MultipleSectionModel in
                                if let parentId = comment.parentId {
                                    if data.id != parentId {
                                        return .ReCommentSection(title: "ReCommentSection", items: [.ReCommentItem(item: comment)])
                                    } else {
                                        return .CommentSection(title: "CommentSection", items: [.CommentItem(item: comment)])
                                    }
                                } else {
                                    return .CommentSection(title: "CommentSection", items: [.CommentItem(item: comment)])
                                }
                            })
                        
                        // add PostSection to first index
                        comments.insertFirst(.PostSection(title: "PostSection", items: [.PostItem(item: defaultPost)]))
                        
                        // return datasource for Table
                        return Single.just(comments)
                    }
                    return Single.just([])
                } catch {
                    return Single.just([])
                }
            })
    }
    
    public func writePost(_ title: String, contents: String, imageUrls: [String], categoryId: Int) -> Observable<WritePostResponse> {
        return BuzzlerProvider.request(Buzzler.writePost(title: title, contents: contents,  imageUrls: imageUrls, categoryId: categoryId))
            .retry(3)
            .filterSuccessfulStatusCodes()
            .observeOn(MainScheduler.instance)
            .flatMap({ res -> Single<WritePostResponse> in
                let responseData = try res.mapObject(WritePostResponse.self)
                return Single.just(responseData)
            })
    }
    
    public func writeComment(categoryId: Int, postId: Int, parentId: String?, contents: String) -> Observable<Bool> {
        return BuzzlerProvider.request(Buzzler.writeComment(categoryId: categoryId, postId: postId, parentId: parentId, contents: contents))
            .retry(3)
            .filterSuccessfulStatusCodes()
            .observeOn(MainScheduler.instance)
            .mapJSON()
            .flatMap({ res -> Single<Bool> in
                return Single.just(true)
            })
    }
    
    public func requestCode(receiver: String) -> Observable<Bool> {
        return BuzzlerProvider.request(Buzzler.requestCode(receiver: receiver))
            .retry(3)
            .observeOn(MainScheduler.instance)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .flatMap({ res -> Single<Bool> in
                return Single.just(true)
            })
    }

    public func signIn(email: String, password: String) -> Observable<LoginResponse> {
        return BuzzlerProvider.request(Buzzler.signIn(email: email, password: password))
            .retry(3)
            .observeOn(MainScheduler.instance)
            .filterSuccessfulStatusCodes()
            .flatMap({ res -> Single<LoginResponse> in
                let responseData = try res.mapObject(LoginResponse.self)
                
                if let success = responseData.result {
                    let token = success.authToken
                    // add userDefaults
                    var environment = Environment()
                    environment.token = token
                    // save auto login info
                    if let autoLogin = environment.autoLogin, autoLogin {
                        environment.receiver = email
                        environment.password = password
                    }
                    // save email info
                    if let saveEmail = environment.saveEmail, saveEmail {
                        environment.receiver = email
                    }
                }
                return Single.just(responseData)
            })
    }
    
    public func getUserInfo(loginResult: LoginResponse) -> Observable<LoginResponse> {
        return BuzzlerProvider.request(Buzzler.getUserInfo())
            .retry(3)
            .observeOn(MainScheduler.instance)
            .filterSuccessfulStatusCodes()
            .flatMap({ res -> Single<LoginResponse> in
                let responseData = try res.mapObject(AccountsResponse.self)
                
                if let _ = responseData.error {
                    return Single.just(loginResult)
                }
                
                if let success = responseData.result {
                    // save to static value
                    globalPostCategories = success.postCategories
                    globalAccountInfo = success.account
                    
                    // create SideModel for SideSectionModel
                    sideCategories = globalPostCategories.map{ category in
                        return SideModel.category(id: category.id, title: category.name)
                    }
                    sideCategories.append(SideModel.myPage(navTitle: "MyPageNavigationController"))
                    sideCategories.append(SideModel.settings(navTitle: "SettingsNavigationController"))
                    
                    // save default categoryId
                    var environment = Environment()
                    environment.categoryId = 1
                    environment.categoryTitle = "익명"
                    
                    return Single.just(loginResult)
                }
                return Single.just(loginResult)
            })
    }
}

// MARK: - AWS API

extension API {
    
    public func uploadS3(_ categoryId: Int, fileName: String, encodedImage: String) -> Observable<String> {
        return AwsProvider.request(AWS.uploadS3(categoryId: categoryId, fileName: fileName, encodedImage: encodedImage))
            .retry(3)
            .filterSuccessfulStatusCodes()
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
