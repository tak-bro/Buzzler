//
//  PostCategory.swift
//  Buzzler
//
//  Created by 진형탁 on 27/08/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import ObjectMapper

public struct PostCategory: Mappable {
    var id: Int = 0
    var categoryDepth: Int = 0
    var name: String = ""

    public init?(map: Map) { }
    
    init() { }
    
    mutating public func mapping(map: Map) {
        id <- map["id"]
        categoryDepth <- map["categoryDepth"]
        name <- map["name"]
    }
    
    init(id: Int, categoryDepth: Int, name: String) {
        self.id = id
        self.categoryDepth = categoryDepth
        self.name = name
    }
}
