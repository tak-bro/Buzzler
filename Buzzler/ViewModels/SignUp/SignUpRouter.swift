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
    case verifyCode
    case done
}

struct UserInfo {
    var recevier: String?
    var nickName: String?
    var password: String?
    
    init() {
        self.recevier = ""
        self.nickName = ""
        self.password = ""
    }
    
    init(receiver: String, nickName: String, password: String) {
        self.recevier = receiver
        self.nickName = nickName
        self.password = password
    }
}

class SignUpRouter {
    
    var userInfo = UserInfo()
    
    func perform(_ segue: SignUpSegue, from source: UIViewController) {
        switch segue {
        case .verifyCode:
            let verifyCodeVC = SignUpRouter.makeVerifyCodeViewController(withUserInfo: userInfo)
            source.navigationController?.pushViewController(verifyCodeVC, animated: true)
        case .done:
            let signUpDoneVC = SignUpRouter.makeSignUpDoneViewController()
            source.navigationController?.pushViewController(signUpDoneVC, animated: true)
        }
    }
}

// MARK: Helpers
private extension SignUpRouter {

    static func makeVerifyCodeViewController(withUserInfo userInfo: UserInfo) -> VerifyCodeViewController {
        let verifyCodeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VerifyCodeViewController") as! VerifyCodeViewController
        verifyCodeVC.inputUserInfo = userInfo
        return verifyCodeVC
    }
    
    static func makeSignUpDoneViewController() -> SignUpDoneViewController {
        let signUpDoneVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpDoneViewController") as! SignUpDoneViewController
        return signUpDoneVC
    }
}
