//
//  SideMenuRouter.swift
//  Buzzler
//
//  Created by 진형탁 on 24/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import Foundation
import UIKit

enum SideMenuSegue {
    case myPage
    case settings
    case home
}

class SideMenuRouter {
    
    var category: Int = 1
    
    func perform(_ segue: SideMenuSegue, from source: UIViewController) {
        switch segue {
        case .myPage:
            let myPageVC = SideMenuRouter.makeMyPageViewController()
            source.navigationController?.pushViewController(myPageVC, animated: false)
        case .settings:
            let settingsVC = SideMenuRouter.makeSettingsViewController()
            source.navigationController?.pushViewController(settingsVC, animated: false)
        case .home:
            let homeVC = SideMenuRouter.makeHomeViewController(withCategory: category)
            source.navigationController?.pushViewController(homeVC, animated: false)
        }
    }
}

// MARK: Helpers
private extension SideMenuRouter {
    
    static func makeMyPageViewController() -> MyPageViewController {
        let myPageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyPageViewController") as! MyPageViewController
        return myPageVC
    }
    
    static func makeSettingsViewController() -> SettingsViewController {
        let settingsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        return settingsVC
    }
    
    static func makeHomeViewController(withCategory selectedCategory: Int)-> HomeViewController {
        let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        homeVC.category = selectedCategory
        return homeVC
    }

}

