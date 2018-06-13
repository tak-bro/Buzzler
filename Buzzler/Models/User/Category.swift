//
//  Category.swift
//  Buzzler
//
//  Created by 진형탁 on 13/06/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import ObjectMapper

public struct UserCategory: Mappable {
    var id: Int = 0
    var categoryDepth: Int = 0
    var name: String = ""
    var baseUrl: String? = ""
    var secondUrl: String? = ""
    var createdAt: Date = Date()
    
    public init?(map: Map) { }
    
    init() { }
    
    mutating public func mapping(map: Map) {
        id <- map["id"]
        categoryDepth <- map["categoryDepth"]
        name <- map["name"]
        baseUrl <- map["baseUrl"]
        secondUrl <- map["secondUrl"]
        createdAt <- map["createdAt"]
    }
    
    init(id: Int, categoryDepth: Int, name: String, baseUrl: String?, secondUrl: String?, createdAt: Date) {
        if let baseUrl = baseUrl {
            self.baseUrl = baseUrl
        }
        if let secondUrl = secondUrl {
            self.secondUrl = secondUrl
        }
        
        self.id = id
        self.categoryDepth = categoryDepth
        self.name = name
        self.createdAt = createdAt
    }
}

// TODO: temp save data to global var
var userCategories = [UserCategory]()
