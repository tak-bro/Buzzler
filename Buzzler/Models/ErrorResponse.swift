//
//  ErrorResponse.swift
//  Buzzler
//
//  Created by 진형탁 on 24/08/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import ObjectMapper

public struct ErrorResponse: Mappable {
    var code: Int = 0
    var message: String = ""

    public init?(map: Map) { }
    
    init() { }
    
    mutating public func mapping(map: Map) {
        code <- map["code"]
        message <- map["message"]
    }
    
    init(code: Int, message: String) {
        self.code = code
        self.message = message
    }
}
