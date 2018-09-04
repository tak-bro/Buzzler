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

public struct BuzzlerPost: Equatable, Mappable {
    
    var id: Int = 0
    var title: String = ""
    var contents: String = ""
    var imageUrls: [String] = []
    var likeCount: Int = 0
    var commentCount: Int = 0
    var createdAt: String = ""
    var liked: Bool = false
    var author: Author = Author()
    
    public static func == (lhs: BuzzlerPost, rhs: BuzzlerPost) -> Bool {
        return lhs.id == rhs.id ? true : false
    }
    
    public init?(map: Map) { }
    
    init() { }
    
    mutating public func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        contents <- map["contents"]
        imageUrls <- map["imageUrls"]
        likeCount <- map["likeCount"]
        commentCount <- map["commentCount"]
        createdAt <- map["createdAt"]
        author <- map["author"]
        liked <- map["liked"]
    }
    
    init(id: Int, title: String, contents: String, commentCount: Int,
         imageUrls: [String], likeCount: Int, createdAt: String,
         author: Author, liked: Bool) {
        self.id = id
        self.title = title
        self.contents = contents
        self.imageUrls = imageUrls
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.createdAt = createdAt
        self.author = author
        self.liked = liked
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
