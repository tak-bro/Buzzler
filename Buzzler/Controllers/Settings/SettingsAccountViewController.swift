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

        self.navigationController?.navigationBar.topItem?.title = " "
        SideMenuManager.menuWidth = view.frame.width * CGFloat(0.64)
        addThinShadowToNav(from: self)

        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "계정"
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
        setSimpleBorderToView(view: self.vw_userName)
        setSimpleBorderToView(view: self.vw_email)
        setSimpleBorderToView(view: self.vw_univ)
        setSimpleBorderToView(view: self.vw_major)
        setSimpleBorderToView(view: self.vw_changePassword)
        
        setUserInfoLabel()
    }


}
