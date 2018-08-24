//
//  WritePostResponse.swift
//  Buzzler
//
//  Created by 진형탁 on 24/08/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import ObjectMapper

public struct WritePostSuccess: Mappable {
    var id: Int = 0
    var author: Author = Author()
    var title: String = ""
    var contents: String = ""
    var imageUrls: [String] = []
    
    public init?(map: Map) { }
    
    init() { }
    
    mutating public func mapping(map: Map) {
        id <- map["id"]
        author <- map["author"]
        title <- map["title"]
        contents <- map["contents"]
        imageUrls <- map["imageUrls"]
    }
    
    init(id: Int, title: String, contents: String, imageUrls: [String], author: Author) {
        self.id = id
        self.title = title
        self.contents = contents
        self.imageUrls = imageUrls
        self.author = author
    }
}

public struct WritePostResponse: Mappable {
    var error: ErrorResponse?
    var result: WritePostSuccess?
    
    public init?(map: Map) { }
    
    init() { }
    
    mutating public func mapping(map: Map) {
        error <- map["error"]
        result <- map["result"]
    }
    
    init(error: ErrorResponse?, result: WritePostSuccess?) {
        self.error = error
        self.result = result
    }
}
