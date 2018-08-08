//
//  AccountInfo
//  Buzzler
//
//  Created by 진형탁 on 08/08/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import ObjectMapper

public struct AccountInfo: Mappable {
    var id: Int = 0
    var username: String = ""
    var email: String = ""
    var buzAmount: Int = 0

    public init?(map: Map) { }
    
    init() { }
    
    mutating public func mapping(map: Map) {
        id <- map["id"]
        username <- map["username"]
        email <- map["email"]
        buzAmount <- map["buzAmount"]
    }
    
    init(id: Int, username: String, email: String, buzAmount: Int) {
        self.id = id
        self.username = username
        self.email = email
        self.buzAmount = buzAmount
    }
}

// TODO: temp save data to global var
var globalAccountInfo = AccountInfo()
