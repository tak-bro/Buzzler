//
//  AccountsResponse.swift
//  Buzzler
//
//  Created by 진형탁 on 27/08/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import ObjectMapper

public struct AccountsSuccess: Mappable {
    var account: AccountInfo = AccountInfo()
    var postCategories: [PostCategory] = []

    public init?(map: Map) { }
    
    init() { }
    
    mutating public func mapping(map: Map) {
        account <- map["account"]
        postCategories <- map["postCategories"]
    }
    
    init(account: AccountInfo, postCategories: [PostCategory]) {
        self.account = account
        self.postCategories = postCategories
    }
}


public struct AccountsResponse: Mappable {
    var error: ErrorResponse?
    var result: AccountsSuccess?
    
    public init?(map: Map) { }
    
    init() { }
    
    mutating public func mapping(map: Map) {
        error <- map["error"]
        result <- map["result"]
    }
    
    init(error: ErrorResponse?, result: AccountsSuccess?) {
        self.error = error
        self.result = result
    }
}
