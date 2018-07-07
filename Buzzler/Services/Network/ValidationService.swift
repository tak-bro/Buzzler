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
import Photos
import DKImagePickerController

public struct PostImage {
    var fileName: String
    var encodedImgData: String
}

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
    func validateCode(_ code: String) -> Observable<ValidationResult>
    func validateEmail(_ email: String) -> Observable<ValidationResult>
    func validateUserId(_ userId: String) -> Observable<ValidationResult>
    func validateTextString(_ text: String) -> ValidationResult
    func validateConfirmPassword(password: String, confirmPassword: String) -> ValidationResult
}

public class BuzzlerDefaultValidationService: BuzzlerValidationService {
    
    static let sharedValidationService = BuzzlerDefaultValidationService()
    
    public func encodedImages(_ images: [DKAsset]) -> [PostImage] {
        var encoded: [PostImage] = [PostImage]()
        
        for i in 0..<images.count {
            images[i].fetchOriginalImage(true, completeBlock: { image, info in
                guard let file = images[i].originalAsset?.originalFileName else { return }
                guard let image = image else { return }
                guard let representedData = UIImageJPEGRepresentation(image, 0.5) else { return }
                
                let encodedData = representedData.base64EncodedString()
                let fileName = file.fileName() + ".JPEG"
                let data = PostImage(fileName: fileName, encodedImgData: encodedData)
                encoded.append(data)
            })
        }
        
        return encoded
    }
    
    public func validateCode(_ code: String) -> Observable<ValidationResult> {
        if code.count < 5 {
            return .just(.empty)
        } else {
            return .just(.ok(message: "Verification Code available"))
        }
    }
    
    public func validateEmail(_ email: String) -> Observable<ValidationResult> {
        if validateStudentEmail(enteredEmail: email) {
            return .just(.ok(message: "Email available"))
        } else {
            return .just(.empty)
        }
    }
    
    public func validateUserId(_ userId: String) -> Observable<ValidationResult> {
        if userId.count < 6 {
            return .just(.empty)
        } else {
            return .just(.ok(message: "Username available"))
        }
    }
    
    public func validateTextString(_ text: String) -> ValidationResult {
        if text.count == 0 {
            return .empty
        } else {
            return .ok(message: "Text acceptable")
        }
    }
    
    public func validateConfirmPassword(password: String, confirmPassword: String) -> ValidationResult {
        if password != confirmPassword {
            return .empty
        } else {
            return .ok(message: "Passwords matched")
        }
    }
}
