//
//  DetailPostResponse.swift
//  Buzzler
//
//  Created by 진형탁 on 27/08/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import ObjectMapper

public struct DetailPostResponse: Mappable {
    var error: ErrorResponse?
    var result: DetailBuzzlerPost?
    
    public init?(map: Map) { }
    
    init() { }
    
    mutating public func mapping(map: Map) {
        error <- map["error"]
        result <- map["result"]
    }
    
    init(error: ErrorResponse, result: DetailBuzzlerPost) {
        self.error = error
        self.result = result
    }
}
