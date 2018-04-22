//
//  BuzzlerError.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 18..
//  Copyright © 2018년 Maru. All rights reserved.
//

import Foundation

enum BuzzlerError: Error {
    case notAuthenticated
    case rateLimitExceeded
    case wrongJSONParsing
    case generic
}
