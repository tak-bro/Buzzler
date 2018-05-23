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
    case writePost(title: String, content: String, imageUrls: [String])
    case getPost(category: Int)
    case requestCode(receiver: String)
    case verifyCode(receiver: String, verificationCode: String)
    case signUp(username: String, email: String, password: String, categoryAuth: [String])
    case signIn(email: String, password: String)
    case getMajor()
    case getUniv(email: String)
}

extension Buzzler: TargetType {
    public var baseURL: URL {
        return URL(string: Dev.hostURL)!
    }
    
    public var path: String {
        switch self {
        case .writePost(_, _, _):   // POST
            return "/v1/posts"
        case .getPost(let category):
            return "/v1/categories/\(category)/posts"
        case .requestCode:  // POST
            return "/v1/accounts/email-verification"
        case .verifyCode:   // PUT
            return "/v1/accounts/email-verification"
        case .signUp:  // POST
            return "/v1/accounts/signup"
        case .signIn:  // POST
            return "/v1/accounts/signin"
        case .getUniv:  // GET
            return "/v1/categories"
        case .getMajor:  // GET
            return "/v1/categories"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        // GET
        case .getPost(_),
             .getMajor(_),
             .getUniv(_):
            return .get
            
        // POST
        case .writePost(_, _, _),
            .requestCode(_),
            .signUp(_, _, _, _),
            .signIn(_, _):
            return .post
       
        // PUT
        case .verifyCode(_, _):
            return .put
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .getUniv(email: let email):
            return ["depth": 1, "email": email]
        case .getMajor():
            return ["depth": 2]
        case .getPost(category: _):
            return nil
        case .writePost(let title, let content, let imageUrls):
            return ["title": title, "content": content, "imageUrls": imageUrls]
        case .requestCode(let receiver):
            return ["receiver": receiver]
        case .verifyCode(let receiver, let verificationCode):
            return ["receiver": receiver, "verificationCode": verificationCode]
        case .signUp(let username, let email, let password, let categoryAuth):
            return ["username": username, "email": email, "password": password, "categoryAuth": categoryAuth]
        case .signIn(let email, let password):
            return ["email": email, "password": password]
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
    case .getPost:
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
