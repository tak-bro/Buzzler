//
//  SignUpResult.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 22..
//  Copyright © 2018년 Maru. All rights reserved.
//

import Foundation

enum SignUpResult {
    case ok
    case failed(message: String)
}

enum VerifyResult {
    case ok
    case failed(message: String)
}

extension SignUpResult: Equatable {}
func == (lhs: SignUpResult, rhs: SignUpResult) -> Bool {
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
