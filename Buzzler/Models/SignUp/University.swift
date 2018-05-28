//
//  University.swift
//  Buzzler
//
//  Created by 진형탁 on 21/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import SwiftyJSON

struct University {
    let id: Int
    let categoryDepth: Int
    let name: String
    let baseUrl: String
    let secondUrl: String
    let createdAt: Date
}

extension University: Decodable {
    static func fromJSON(_ json: AnyObject) -> University {
        let json = JSON(json)
        
        let id = json["id"].intValue
        let categoryDepth = json["categoryDepth"].intValue
        let name = json["name"].stringValue
        let baseUrl = json["baseUrl"].stringValue
        let secondUrl = json["secondUrl"].stringValue
        let createdAt = Date(httpDateString: json["createdAt"].stringValue)

        return University(id: id,
                          categoryDepth: categoryDepth,
                          name: name,
                          baseUrl: baseUrl,
                          secondUrl: secondUrl,
                          createdAt: createdAt!
        )
    }
}
