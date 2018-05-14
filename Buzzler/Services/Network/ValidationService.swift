//
//  ValidationService.swift
//  Buzzler
//
//  Created by 진형탁 on 14/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public enum ValidationResult {
    case ok(message: String)
    case empty
    case validating
    case failed(message: String)
}

extension ValidationResult {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}

public protocol BuzzlerValidationService {
    func validateUserid(_ userid: String) -> Observable<ValidationResult>
    func validatePassword(_ password: String) -> ValidationResult
}

public class BuzzlerDefaultValidationService: BuzzlerValidationService {
    
    static let sharedValidationService = BuzzlerDefaultValidationService()
    
    public func validateUserid(_ userid: String) -> Observable<ValidationResult> {
        if userid.count < 6 {
            return .just(.empty)
        } else {
            return .just(.ok(message: "Username available"))
        }
    }
    
    public func validatePassword(_ password: String) -> ValidationResult {
        if password.count == 0 {
            return .empty
        } else {
            return .ok(message: "Password acceptable")
        }
    }
    
}
