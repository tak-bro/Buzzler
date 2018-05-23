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
    case selectUniv
    case selectMajor
    case done
}

class SignUpRouter {
    
    var userInfo = UserInfo()
    var majorList: [MajorInfo] = [MajorInfo]()
    
    func perform(_ segue: SignUpSegue, from source: UIViewController) {
        switch segue {
        case .verifyCode:
            let verifyCodeVC = SignUpRouter.makeVerifyCodeViewController(withUserInfo: userInfo)
            source.navigationController?.pushViewController(verifyCodeVC, animated: true)
        case .selectMajor:
            let selectMajorVC = SignUpRouter.makeSelectMajorViewController(withUserInfo: userInfo, withMajorList: majorList)
            source.navigationController?.pushViewController(selectMajorVC, animated: true)
        case .done:
            let signUpDoneVC = SignUpRouter.makeSignUpDoneViewController()
            source.navigationController?.pushViewController(signUpDoneVC, animated: true)
        case .selectUniv:
            let selectUnivVC = SignUpRouter.makeSelectUnivViewController(withUserInfo: userInfo)
            source.navigationController?.pushViewController(selectUnivVC, animated: true)
        }
    }
}

// MARK: Helpers
private extension SignUpRouter {

    static func makeVerifyCodeViewController(withUserInfo userInfo: UserInfo) -> VerifyCodeViewController {
        let verifyCodeVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "VerifyCodeViewController") as! VerifyCodeViewController
        verifyCodeVC.inputUserInfo = userInfo
        return verifyCodeVC
    }
    
    static func makeSelectMajorViewController(withUserInfo userInfo: UserInfo, withMajorList majorList: [MajorInfo]) -> SelectMajorViewController {
        let selectMajorVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "SelectMajorViewController") as! SelectMajorViewController
        selectMajorVC.inputUserInfo = userInfo
        selectMajorVC.majors = majorList
        return selectMajorVC
    }

    static func makeSelectUnivViewController(withUserInfo userInfo: UserInfo) -> SelectUnivViewController {
        let selectUnivVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "SelectUnivViewController") as! SelectUnivViewController
        selectUnivVC.inputUserInfo = userInfo
        return selectUnivVC
    }
    
    static func makeSignUpDoneViewController() -> SignUpDoneViewController {
        let signUpDoneVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "SignUpDoneViewController") as! SignUpDoneViewController
        return signUpDoneVC
    }
}
