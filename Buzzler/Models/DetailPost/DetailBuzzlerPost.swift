//
//  DetailBuzzlerPost.swift
//  Buzzler
//
//  Created by 진형탁 on 28/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import RxDataSources
import ObjectMapper

public struct DetailBuzzlerPost: Equatable, Mappable {
    
    var id: Int = 0
    var title: String = ""
    var contents: String = ""
    var imageUrls: [String] = []
    var likeCount: Int = 0
    var createdAt: Date = Date()
    var authorId: Int = 0
    var comments: [BuzzlerComment] = []
    
    public static func == (lhs: DetailBuzzlerPost, rhs: DetailBuzzlerPost) -> Bool {
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
        createdAt <- map["createdAt"]
        authorId <- map["authorId"]
        comments <- map["comments"]
    }
    
}

struct DetailBuzzlerSection {
    
    var items: [DetailBuzzlerPost]
}

extension DetailBuzzlerSection: SectionModelType {
    
    typealias Item = DetailBuzzlerPost
    
    init(original: DetailBuzzlerSection, items: [DetailBuzzlerSection.Item]) {
        self = original
        self.items = items
    }
}
