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

let BuzzlerProvider = RxMoyaProvider<Buzzler>(endpointClosure: endpointClosure, plugins: [NetworkLoggerPlugin(verbose: true)])

public enum Buzzler {
    // GET
    case getPost(category: Int)
    case getMajor()
    case getUniv(email: String)
    case getDetailPost(id: Int)
    
    // POST
    case writePost(title: String, content: String, imageUrls: [String])
    case requestCode(receiver: String)
    case signUp(username: String, email: String, password: String, categoryAuth: [String])
    case signIn(email: String, password: String)
    case requestCodeForNewPassword(receiver: String)
    case newPassword(email: String, password: String)
    case writeComment(postId: Int, parentId: Int?, content: String)

    // PUT
    case verifyCode(receiver: String, verificationCode: String)
    case verifyCodeForNewPassword(receiver: String, verificationCode: String)
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
        case .getDetailPost(let id):
            return "v1/posts/\(id)"

        // POST
        case .writePost(_, _, _):
            return "/v1/posts"
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
        case .writeComment(let postId, _, _):
            return "/v1/posts/\(postId)/comments"
            
        // PUT
        case .verifyCode:
            return "/v1/accounts/email-verification"
        case .verifyCodeForNewPassword:
            return "/v1/accounts/newpassword/email-verification"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        // GET
        case .getPost(_),
             .getMajor(_),
             .getUniv(_),
             .getDetailPost(_):
            return .get
            
        // POST
        case .writePost(_, _, _),
            .requestCode(_),
            .signUp(_, _, _, _),
            .signIn(_, _),
            .requestCodeForNewPassword(_),
            .newPassword(_, _),
            .writeComment(_, _, _):
            return .post
       
        // PUT
        case .verifyCode(_, _),
            .verifyCodeForNewPassword(_, _):
            return .put
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
        case .getDetailPost(id: _):
            return nil
            
        // POST
        case .writePost(let title, let content, let imageUrls):
            return ["title": title, "content": content, "imageUrls": imageUrls]
        case .requestCode(let receiver),
             .requestCodeForNewPassword(let receiver):
            return ["receiver": receiver]
        case .signUp(let username, let email, let password, let categoryAuth):
            return ["username": username, "email": email, "password": password, "categoryAuth": categoryAuth]
        case .signIn(let email, let password):
            return ["email": email, "password": password]
        case .newPassword(let email, let password):
            return ["email": email, "newPassword": password]
        case .writeComment(_, let parentId, let content):
            guard let parentId = parentId else { return ["content": content] }
            return ["parentId": parentId, "content": content]

        // PUT
        case .verifyCode(let receiver, let verificationCode),
             .verifyCodeForNewPassword(let receiver, let verificationCode):
            return ["receiver": receiver, "verificationCode": verificationCode]
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
    switch target {
    case .getUniv,
         .getMajor:
        return endpoint.adding(newHTTPHeaderFields: ["Content-Type": "application/json"])
            .adding(newParameterEncoding: URLEncoding.default)
        
    case .getPost,
         .getDetailPost:
        return endpoint.adding(newHTTPHeaderFields: ["Content-Type": "application/json"])
        
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
