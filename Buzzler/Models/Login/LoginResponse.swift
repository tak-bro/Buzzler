//
//  LoginResponse.swift
//  Buzzler
//
//  Created by 진형탁 on 24/08/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import ObjectMapper

public struct LoginSuccess: Mappable {
    var authToken: String = ""

    public init?(map: Map) { }
    
    init() { }
    
    mutating public func mapping(map: Map) {
        authToken <- map["authToken"]
    }
    
    init(authToken: String) {
        self.authToken = authToken
    }
}


public struct LoginResponse: Mappable {
    var error: ErrorResponse?
    var result: LoginSuccess?

    public init?(map: Map) { }
    
    init() { }
    
    mutating public func mapping(map: Map) {
        error <- map["error"]
        result <- map["result"]
    }
    
    init(error: ErrorResponse?, result: LoginSuccess?) {
        self.error = error
        self.result = result
    }
}
