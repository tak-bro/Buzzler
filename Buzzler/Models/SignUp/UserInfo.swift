//
//  UserInfo.swift
//  Buzzler
//
//  Created by 진형탁 on 23/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation

struct UserInfo {
    var recevier: String?
    var nickName: String?
    var password: String?
    var categoryAuth: [Int]?
    
    init() {
        self.recevier = ""
        self.nickName = ""
        self.password = ""
        self.categoryAuth = []
    }
    
    init(receiver: String, nickName: String, password: String) {
        self.recevier = receiver
        self.nickName = nickName
        self.password = password
    }
}
