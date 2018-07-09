//
//  ImageResponse.swift
//  Buzzler
//
//  Created by 진형탁 on 07/07/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import ObjectMapper

public struct ImageReponse: Equatable, Mappable {
    
    var bucket: String = ""
    var fileName: String = ""
    var key: String = ""
    var url: String = ""

    public static func == (lhs: ImageReponse, rhs: ImageReponse) -> Bool {
        return lhs.url == rhs.url ? true : false
    }
    
    public init?(map: Map) { }
    
    init() { }
    
    mutating public func mapping(map: Map) {
        bucket <- map["bucket"]
        fileName <- map["fileName"]
        key <- map["key"]
        url <- map["url"]
    }
    
}
