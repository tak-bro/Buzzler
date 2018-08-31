//
//  VerifyCodeResponse.swift
//  Buzzler
//
//  Created by 진형탁 on 30/08/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import ObjectMapper

public struct VerifyCodeResponse: Mappable {
    var error: ErrorResponse?
    var result: String?
    
    public init?(map: Map) { }
    
    init() { }
    
    mutating public func mapping(map: Map) {
        error <- map["error"]
        result <- map["result"]
    }
    
    init(error: ErrorResponse?, result: String?) {
        self.error = error
        self.result = result
    }
}
