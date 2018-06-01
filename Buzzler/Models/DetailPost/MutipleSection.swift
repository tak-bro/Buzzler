//
//  MutipleSection.swift
//  Buzzler
//
//  Created by 진형탁 on 01/06/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import RxDataSources

public enum MultipleSectionModel {
    case PostSection(title: String, items: [SectionItem])
    case CommentSection(title: String, items: [SectionItem])
}

public enum SectionItem {
    case PostItem(item: BuzzlerPost)
    case CommentItem(item: BuzzlerComment)
}

extension MultipleSectionModel: SectionModelType {
    public typealias Item = SectionItem
    
    public var items: [SectionItem] {
        switch self {
        case .PostSection(title: _, items: let items):
            return items.map {$0}
        case .CommentSection(title: _, items: let items):
            return items.map {$0}
        }
    }
    
    public init(original: MultipleSectionModel, items: [Item]) {
        switch original {
        case let .PostSection(title: title, items: _):
            self = .PostSection(title: title, items: items)
        case let .CommentSection(title, _):
            self = .CommentSection(title: title, items: items)
        }
    }
}

extension MultipleSectionModel {
    var title: String {
        switch self {
        case .PostSection(title: let title, items: _):
            return title
        case .CommentSection(title: let title, items: _):
            return title
        }
    }
}
