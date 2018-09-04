//
//  SettingsAccountViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 04/09/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import UIKit
import SideMenu

class SettingsAccountViewController: UIViewController {
    
    @IBOutlet weak var vw_userName: UIView!
    @IBOutlet weak var vw_email: UIView!
    @IBOutlet weak var vw_univ: UIView!
    @IBOutlet weak var vw_major: UIView!
    @IBOutlet weak var vw_changePassword: UIView!
    
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var lbl_email: UILabel!
    @IBOutlet weak var lbl_univ: UILabel!
    @IBOutlet weak var lbl_major: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SideMenuManager.menuWidth = view.frame.width * CGFloat(0.64)
        addThinShadowToNav(from: self)
        title = "계정"
        
        setUI()
    }

}

extension SettingsAccountViewController {
    
    func setUserInfoLabel() {
        self.lbl_name.text = globalAccountInfo.username
        self.lbl_email.text = globalAccountInfo.email

        if globalPostCategories.count > 2 {
            self.lbl_univ.text = globalPostCategories[2].name
            self.lbl_major.text = globalPostCategories[1].name
        }
    }
    
    func setUI() {
        setBorderToView(view: self.vw_userName)
        setBorderToView(view: self.vw_email)
        setBorderToView(view: self.vw_univ)
        setBorderToView(view: self.vw_major)
        setBorderToView(view: self.vw_changePassword)
        
        setUserInfoLabel()
    }

    func setBorderToView(view: UIView) {
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.00).cgColor
    }
}
