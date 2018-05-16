//
//  SignUpResult.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 22..
//  Copyright © 2018년 Maru. All rights reserved.
//

// TODO: deprecated
// To be deleted

import Foundation

enum VerifyResult {
    case ok
    case failed(message: String)
}

extension VerifyResult: Equatable {}
func == (lhs: VerifyResult, rhs: VerifyResult) -> Bool {
    switch (lhs,rhs) {
    case (.ok, .ok):
        return true
    case (.failed(let x), .failed(let y))
        where x == y:
        return true
    default:
        return false
    }
}
