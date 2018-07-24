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
    func writePost(_ title: String, contents: String, imageUrls: [String], categoryId: Int) -> Observable<Bool>
    func writeComment(categoryId: Int, postId: Int, parentId: String?, contents: String) -> Observable<Bool>
}


public class API: AwsAPI, BuzzlerAPI {
    
    static let sharedAPI = API()
    
    // Buzzler API
    
    public func likePost(categoryId: Int, postId: Int) -> Observable<Bool> {
        return BuzzlerProvider.request(Buzzler.likePost(categoryId: categoryId, postId: postId))
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
                    let data = try res.mapArray(BuzzlerPost.self)
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
                    let data = try res.mapObject(DetailBuzzlerPost.self)
                    // convert response to BuzzlerPost model
                    let defaultPost = BuzzlerPost(id: data.id, title: data.title, contents: data.contents,
                                                  imageUrls: data.imageUrls, likeCount: data.likeCount, createdAt: data.createdAt,
                                                  authorId: data.authorId)
                    
                    // join comments with child
                    let commentsData = data.comments
                        .map { item -> [BuzzlerComment] in
                            var commentsWithChild = [BuzzlerComment]()
                            commentsWithChild.insertFirst(item)
                            
                            if item.childComments.count > 0 {
                                commentsWithChild = commentsWithChild + item.childComments
                            }
                            return commentsWithChild
                        }
                        .flatMap{ $0 }

                    // convert comments to CommentSection
                    var comments = commentsData
                        .map({ (comment: BuzzlerComment) -> MultipleSectionModel in
                            if data.id != comment.parentId {
                                return .ReCommentSection(title: "ReCommentSection", items: [.ReCommentItem(item: comment)])
                            } else {
                                return .CommentSection(title: "CommentSection", items: [.CommentItem(item: comment)])
                            }
                        })
                    
                    // add PostSection to first index
                    comments.insertFirst(.PostSection(title: "PostSection", items: [.PostItem(item: defaultPost)]))
                    
                    // return datasource for Table
                    return Single.just(comments)
                } catch {
                    return Single.just([])
                }
            })
    }
    
    public func writePost(_ title: String, contents: String, imageUrls: [String], categoryId: Int) -> Observable<Bool> {
        return BuzzlerProvider.request(Buzzler.writePost(title: title, contents: contents,  imageUrls: imageUrls, categoryId: categoryId))
            .retry(3)
            .filterSuccessfulStatusCodes()
            .observeOn(MainScheduler.instance)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .flatMap({ res -> Single<Bool> in
                return Single.just(true)
            })
    }
    
    public func writeComment(categoryId: Int, postId: Int, parentId: String?, contents: String) -> Observable<Bool> {
        return BuzzlerProvider.request(Buzzler.writeComment(categoryId: categoryId, postId: postId, parentId: parentId, contents: contents))
            .retry(3)
            .filterSuccessfulStatusCodes()
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
