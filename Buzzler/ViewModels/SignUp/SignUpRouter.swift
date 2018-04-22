//
//  SignUpRouter.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 21..
//  Copyright © 2018년 Maru. All rights reserved.
//

import Foundation
import UIKit

enum SignUpSegue {
    case signUp
    case verifyCode
}

protocol SignUpRouter {
    func perform(_ segue: SignUpSegue, from source: SignUpViewController)
}

class DefaultSignUpRouter: SignUpRouter {
    
    func perform(_ segue: SignUpSegue, from source: SignUpViewController) {
        switch segue {
        case .signUp:
            print("test")
        case .verifyCode:
            let vc = DefaultSignUpRouter.makeVerifyCodeViewController()
            source.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: Helpers
private extension DefaultSignUpRouter {

    static func makeVerifyCodeViewController() -> VerifyCodeViewController {
        let verifyCodeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VerifyCodeViewController") as! VerifyCodeViewController
        return verifyCodeVC
    }
}
