//
//  SettingsViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 20/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import UIKit
import SideMenu

class SettingsViewController: UIViewController {

    @IBOutlet weak var vw_account: UIView!
    @IBOutlet weak var vw_versionInfo: UIView!
    @IBOutlet weak var vw_csCenter: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SideMenuManager.menuWidth = view.frame.width * CGFloat(0.64)
        addThinShadowToNav(from: self)
        title = "Settings"
        
        setUI()
    }
    
    func setUI() {
        // add border to view
        self.vw_account.layer.borderWidth = 1
        self.vw_account.layer.borderColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.00).cgColor
        
        self.vw_versionInfo.layer.borderWidth = 1
        self.vw_versionInfo.layer.borderColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.00).cgColor
        
        self.vw_csCenter.layer.borderWidth = 1
        self.vw_csCenter.layer.borderColor = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.00).cgColor
    }
}
