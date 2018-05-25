//
//  ResetPasswordRouter.swift
//  Buzzler
//
//  Created by 진형탁 on 18/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import UIKit

enum ResetPasswordSegue {
    case secondStep
    case lastStep
    case doneReset
}

class ResetPasswordRouter {
    
    var email: String = ""
    
    func perform(_ segue: ResetPasswordSegue, from source: UIViewController) {
        switch segue {
        case .secondStep:
            let secondStepVC = ResetPasswordRouter.makeSecondStepViewController(withUserEmail: email)
            source.navigationController?.pushViewController(secondStepVC, animated: true)
        case .lastStep:
            let lastStepVC = ResetPasswordRouter.makeLastStepViewController(withUserEmail: email)
            source.navigationController?.pushViewController(lastStepVC, animated: true)
        case .doneReset:
            let doneVC = ResetPasswordRouter.makeDoneVewController()
            source.navigationController?.pushViewController(doneVC, animated: true)
        }
    }
}

private extension ResetPasswordRouter {
    
    static func makeSecondStepViewController(withUserEmail email: String) -> SecondStepViewController {
        let secondStepVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "SecondStepViewController") as! SecondStepViewController
        secondStepVC.userEmail = email
        return secondStepVC
    }
    
    static func makeLastStepViewController(withUserEmail email: String) -> LastStepViewController {
        let lastStepVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "LastStepViewController") as! LastStepViewController
        lastStepVC.userEmail = email
        return lastStepVC
    }
    
    static func makeDoneVewController() -> NewPasswordDoneViewController {
        let doneVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "NewPasswordDoneViewController") as! NewPasswordDoneViewController
        return doneVC
    }
}
