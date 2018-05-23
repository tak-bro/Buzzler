//
//  ResetPasswordRouter.swift
//  Buzzler
//
//  Created by 진형탁 on 18/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import Foundation
import UIKit

enum ResetPasswordSegue {
    case secondStep
    case lastStep
}

class ResetPasswordRouter {
    
    func perform(_ segue: ResetPasswordSegue, from source: UIViewController) {
        switch segue {
        case .secondStep:
            let secondStepVC = ResetPasswordRouter.makeSecondStepViewController()
            source.navigationController?.pushViewController(secondStepVC, animated: true)
        case .lastStep:
            let lastStepVC = ResetPasswordRouter.makeLastStepViewController()
            source.navigationController?.pushViewController(lastStepVC, animated: true)
        }
    }
}

private extension ResetPasswordRouter {
    
    static func makeSecondStepViewController() -> SecondStepViewController {
        let secondStepVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "SecondStepViewController") as! SecondStepViewController
        return secondStepVC
    }
    
    static func makeLastStepViewController() -> LastStepViewController {
        let lastStepVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "LastStepViewController") as! LastStepViewController
        return lastStepVC
    }
}
