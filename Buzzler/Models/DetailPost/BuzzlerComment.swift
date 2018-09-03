//
//  BuzzlerComment.swift
//  Buzzler
//
//  Created by 진형탁 on 01/06/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import RxDataSources
import ObjectMapper

public struct BuzzlerComment: Equatable, Mappable {
    
    var id: Int = 0
    var author: Author = Author()
    var postId: Int = 0
    var parentId: Int?
    var contents: String = ""
    var likeCount: Int = 0
    var createdAt: String = ""
    var childComment: [BuzzlerComment] = [BuzzlerComment]()
    
    public static func == (lhs: BuzzlerComment, rhs: BuzzlerComment) -> Bool {
        return lhs.id == rhs.id ? true : false
    }
    
    public init?(map: Map) { }
    
    init() { }
    
    mutating public func mapping(map: Map) {
        id <- map["id"]
        author <- map["author"]
        postId <- map["postId"]
        parentId <- map["parentId"]
        contents <- map["contents"]
        createdAt <- map["createdAt"]
        likeCount <- map["likeCount"]
        childComment <- map["childComment"]
    }
    
}

extension BuzzlerComment {
    
    func customCompare(e2: BuzzlerComment) -> ComparisonResult {
        if let e1ParentId = parentId, let e2ParentId = e2.parentId {
            // return intCompare(e1: e1ParentId, e2: e2ParentId)
            if e1ParentId != e2ParentId {
                return intCompare(e1: e1ParentId, e2: e2ParentId)
            } else {
                return intCompare(e1: id, e2: e2.id)
            }
        } else if let e1ParentId = parentId, e2.parentId == nil {
            return intCompare(e1: e1ParentId, e2: e2.id)
        } else if parentId == nil, let e2ParentId = e2.parentId {
            return intCompare(e1: id, e2: e2ParentId)
        } else {
            // parentId가 없을 때
            return intCompare(e1: id, e2: e2.id)
        }
    }
    
    func idCompare(e2: BuzzlerComment) -> ComparisonResult {
        return intCompare(e1: id, e2: e2.id)
    }

    func createdAtCompare(e2: BuzzlerComment) -> ComparisonResult {
        return createdAt.compare(e2.createdAt)
    }

    func ascCreatedAtCompare(e2: BuzzlerComment) -> ComparisonResult {
        return e2.createdAt.compare(createdAt)
    }
    
}


struct BuzzlerCommentSection {
    
    var items: [BuzzlerComment]
}

extension BuzzlerCommentSection: SectionModelType {
    
    typealias Item = BuzzlerComment
    
    init(original: BuzzlerCommentSection, items: [BuzzlerCommentSection.Item]) {
        self = original
        self.items = items
    }
}
