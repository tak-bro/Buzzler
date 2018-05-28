//
//  MajorInfo.swift
//  Buzzler
//
//  Created by 진형탁 on 23/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation

struct MajorInfo {
    var categoryDepth: Int?
    var id: String?
    var name: String?
    
    init() {
        self.categoryDepth = 2
        self.id = ""
        self.name = ""
    }
    
    init(categoryDepth: Int, id: String, name: String) {
        self.categoryDepth = categoryDepth
        self.id = id
        self.name = name
    }
}
