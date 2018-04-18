//
//  LoginResult.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 18..
//  Copyright © 2018년 Maru. All rights reserved.
//

import Foundation

enum LoginResult {
    case ok
    case failed(message: String)
}

extension LoginResult: Equatable {}

func == (lhs: LoginResult, rhs: LoginResult) -> Bool {
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
