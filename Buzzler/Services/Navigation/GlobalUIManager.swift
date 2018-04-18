//
//  GlobalUIManager.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 18..
//  Copyright © 2018년 Maru. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    class func vcInMainSB(_ identifier: String, sbName: String = "Main") -> UIViewController {
        let sb = UIStoryboard(name: sbName, bundle: nil)
        return sb.instantiateViewController(withIdentifier: identifier)
    }
    
}

class GlobalUIManager {
    class func loadHomeVC() {
        let kWindow: UIWindow = UIApplication.shared.keyWindow!
        let rootVC = UIStoryboard.vcInMainSB("MainTabBarController")
        rootVC.modalTransitionStyle = .crossDissolve
        UIView.transition(with: kWindow,
                          duration: 1,
                          options: .transitionCrossDissolve,
                          animations: {
                            let oldState = UIView.areAnimationsEnabled
                            UIView.setAnimationsEnabled(false)
                            kWindow.rootViewController = rootVC
                            kWindow.makeKeyAndVisible()
                            UIView.setAnimationsEnabled(oldState)
                            
        }, completion: nil)
    }
    
    class func loadLoginVC() {
        let kWindow: UIWindow = UIApplication.shared.keyWindow!
        let rootVC = UIStoryboard.vcInMainSB("LoginRootViewController")
        rootVC.view.alpha = 1
        rootVC.modalTransitionStyle = .crossDissolve
        UIView.transition(with: kWindow,
                          duration: 1,
                          options: .transitionCrossDissolve,
                          animations: {
                            let oldState = UIView.areAnimationsEnabled
                            UIView.setAnimationsEnabled(false)
                            kWindow.rootViewController = rootVC
                            kWindow.makeKeyAndVisible()
                            UIView.setAnimationsEnabled(oldState)
        })
    }
}
