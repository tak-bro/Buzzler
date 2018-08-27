//
//  BuzzlerAPI.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 18..
//  Copyright © 2018년 Maru. All rights reserved.
//

import Foundation
import Moya
import RxSwift

public let BuzzlerProvider = RxMoyaProvider<Buzzler>(endpointClosure: endpointClosure, plugins: [NetworkLoggerPlugin(verbose: true)])

public enum Buzzler {
    // GET
    case getPost(category: Int)
    case getMajor()
    case getUniv(email: String)
    case getDetailPost(categoryId: Int, id: Int)
    case getCategoriesByUser()
    case getUserInfo()
    
    // POST
    case writePost(title: String, contents: String, imageUrls: [String], categoryId: Int)
    case requestCode(receiver: String)
    case signUp(username: String, email: String, password: String, categoryAuth: [String])
    case signIn(email: String, password: String)
    case requestCodeForNewPassword(receiver: String)
    case newPassword(email: String, password: String)
    case writeComment(categoryId: Int, postId: Int, parentId: String?, contents: String)
    case createCategory(depth: Int, name: String, baseUrl: String?)

    // PUT
    case verifyCode(receiver: String, verificationCode: String)
    case verifyCodeForNewPassword(receiver: String, verificationCode: String)

    // DELETE
    case deletePost(postId: Int)
    
    // POST
    case likePost(categoryId: Int, postId: Int)
}

extension Buzzler: TargetType {
    public var baseURL: URL {
        return URL(string: Dev.hostURL)!
    }
    
    public var path: String {
        switch self {
        // GET
        case .getPost(let category):
            return "/v1/categories/\(category)/posts"
        case .getMajor:
            return "/v1/categories"
        case .getUniv:
            return "/v1/categories"
        case .getDetailPost(let categoryId, let id):
            return "v1/categories/\(categoryId)/posts/\(id)"
        case .getCategoriesByUser():
            return "v1/accounts"
        case .getUserInfo():
            return "v1/accounts"
            
        // POST
        case .writePost(_, _, _, let categoryId):
            return "/v1/categories/\(categoryId)/posts"
        case .requestCode:
            return "/v1/accounts/email-verification"
        case .signUp:
            return "/v1/accounts/signup"
        case .signIn:
            return "/v1/accounts/signin"
        case .requestCodeForNewPassword:
            return "/v1/accounts/newpassword/email-verification"
        case .newPassword:
            return "/v1/accounts/newpassword"
        case .writeComment(let categoryId, let postId, _, _):
            return "/v1/categories/\(categoryId)/posts/\(postId)/comments"
        case .createCategory(_, _, _):
            return "/v1/categories"
        case .likePost(let categoryId, let postId):
            return "/v1/categories/\(categoryId)/posts/\(postId)/like"

        // PUT
        case .verifyCode:
            return "/v1/accounts/email-verification"
        case .verifyCodeForNewPassword:
            return "/v1/accounts/newpassword/email-verification"
            
        // DELETE
        case .deletePost(let postId):
            return "/v1/posts/\(postId)"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        // GET
        case .getPost(_),
             .getMajor(_),
             .getUniv(_),
             .getDetailPost(_, _),
             .getCategoriesByUser(),
             .getUserInfo():
            return .get
            
        // POST
        case .writePost(_, _, _, _),
             .requestCode(_),
             .signUp(_, _, _, _),
             .signIn(_, _),
             .requestCodeForNewPassword(_),
             .newPassword(_, _),
             .writeComment(_, _, _, _),
             .createCategory(_, _, _),
             .likePost(_, _):
            return .post
            
        // PUT
        case .verifyCode(_, _),
             .verifyCodeForNewPassword(_, _):
            return .put
            
        // DELETE
        case .deletePost(_):
            return .delete
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        // GET
        case .getPost(category: _):
            return nil
        case .getUniv(email: let email):
            return ["depth": 1, "email": email]
        case .getMajor():
            return ["depth": 2]
        case .getDetailPost(categoryId: _, id: _):
            return nil
        case .getCategoriesByUser():
            return nil
        case .getUserInfo():
            return nil
            
        // POST
        case .writePost(let title, let contents, let imageUrls, _):
            return ["title": title, "contents": contents, "imageUrls": imageUrls]
        case .requestCode(let receiver),
             .requestCodeForNewPassword(let receiver):
            return ["receiver": receiver]
        case .signUp(let username, let email, let password, let categoryAuth):
            return ["username": username, "email": email, "password": password, "categoryAuth": categoryAuth]
        case .signIn(let email, let password):
            return ["email": email, "password": password]
        case .newPassword(let email, let password):
            return ["email": email, "newPassword": password]
        case .writeComment(_, _, let parentId, let contents):
            guard let parentId = parentId else { return ["content": contents] }
            return ["parentId": parentId, "content": contents]
        case .createCategory(let depth, let name, let baseUrl):
            guard let baseUrl = baseUrl else { return ["depth": depth, "name": name] }
            return ["depth": depth, "name": name, "baseUrl": baseUrl]
        case .likePost(_, _):
            return nil
            
        // PUT
        case .verifyCode(let receiver, let verificationCode),
             .verifyCodeForNewPassword(let receiver, let verificationCode):
            return ["receiver": receiver, "verificationCode": verificationCode]
            
        // DELETE
        case .deletePost(_):
            return nil
        }
    }
    
    public var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    public var sampleData: Data {
        return "this is a sample data".data(using: String.Encoding.utf8)!
    }
    
    public var task: Task {
        return .request
    }
}

var endpointClosure = { (target: Buzzler) -> Endpoint<Buzzler> in
    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
    let endpoint: Endpoint<Buzzler> = Endpoint(url: url,
                                               sampleResponseClosure: {.networkResponse(200, target.sampleData)},
                                               method: target.method,
                                               parameters: target.parameters
    )
    let environment = Environment()
    
    switch target {
    case .getUniv,
         .getMajor:
        return endpoint.adding(newHTTPHeaderFields: ["Content-Type": "application/json"])
            .adding(newParameterEncoding: URLEncoding.default)
        
    case .getCategoriesByUser,
         .writeComment,
         .writePost,
         .getPost:
        return endpoint.adding(newHTTPHeaderFields: ["Content-Type": "application/json"])
            .adding(newHTTPHeaderFields: ["Authorization": "\(environment.token!)"])
            .adding(newParameterEncoding: JSONEncoding.default)
        
    case .getDetailPost,
         .deletePost,
         .likePost,
         .getUserInfo:
        return endpoint.adding(newHTTPHeaderFields: ["Content-Type": "application/json"])
            .adding(newHTTPHeaderFields: ["Authorization": "\(environment.token!)"])
        
    default:
        return endpoint
            .adding(newHTTPHeaderFields: ["Content-Type": "application/json"])
            .adding(newParameterEncoding: JSONEncoding.default)
    }
}

private extension String {
    var URLEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)!
    }
}
