//
//  AwsAPI.swift
//  Buzzler
//
//  Created by 진형탁 on 07/07/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import Moya
import RxSwift

public let AwsProvider = RxMoyaProvider<AWS>(endpointClosure: awsEndpointClosure, plugins: [NetworkLoggerPlugin(verbose: true)])

public enum AWS {
    case uploadS3(categoryId: Int, fileName: String, encodedImage: String)
}

extension AWS: TargetType {
    public var baseURL: URL {
        return URL(string: Dev.awsGatewayURL)!
    }
    
    public var path: String {
        switch self {
        case .uploadS3(let categoryId, _, _):
            return "/courses/\(categoryId)/reviews/images"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        // POST
        case .uploadS3(_):
            return .post
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .uploadS3(_, let fileName, let encodedImage):
            return ["name": fileName, "image": encodedImage]
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

var awsEndpointClosure = { (target: AWS) -> Endpoint<AWS> in
    let url = target.baseURL.appendingPathComponent(target.path).absoluteString
    let endpoint: Endpoint<AWS> = Endpoint(url: url,
                                               sampleResponseClosure: {.networkResponse(200, target.sampleData)},
                                               method: target.method,
                                               parameters: target.parameters
    )
    let environment = Environment()
    
    switch target {
    case .uploadS3:
        return endpoint.adding(newHTTPHeaderFields: ["Content-Type": "application/json"])
            .adding(newHTTPHeaderFields: ["x-api-key": "\(Dev.apiKey)"])
            .adding(newParameterEncoding: JSONEncoding.default)
        
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
