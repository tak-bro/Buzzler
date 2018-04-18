//
//  Decodable.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 18..
//  Copyright © 2018년 Maru. All rights reserved.
//

import Foundation

protocol Decodable {
    static func fromJSON(_ json: AnyObject) -> Self
}

extension Decodable {
    static func fromJSONArray(_ json: [AnyObject]) -> [Self] {
        return json.map { Self.fromJSON($0) }
    }
}
