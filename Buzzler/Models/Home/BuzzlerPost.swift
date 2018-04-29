//
//  Post.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 22..
//  Copyright © 2018년 Maru. All rights reserved.
//

import Foundation
import RxDataSources
import ObjectMapper

struct BuzzlerPost: Equatable, Mappable {
    
    var id: Int = 0
    var title: String = ""
    var content: String = ""
    var imageUrls: [String] = []
    var likeCount: Int = 0
    var createdAt: Date = Date()
    var authorId: Int = 0
    
    public static func == (lhs: BuzzlerPost, rhs: BuzzlerPost) -> Bool {
        return lhs.id == rhs.id ? true : false
    }
    
    init?(map: Map) { }
    
    init() { }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        content <- map["content"]
        imageUrls <- map["imageUrls"]
        likeCount <- map["likeCount"]
        createdAt <- map["createdAt"]
        authorId <- map["authorId"]
    }
}

struct BuzzlerSection {
    
    var items: [BuzzlerPost]
}

extension BuzzlerSection: SectionModelType {
    
    typealias Item = BuzzlerPost
    
    init(original: BuzzlerSection, items: [BuzzlerSection.Item]) {
        self = original
        self.items = items
    }
}
