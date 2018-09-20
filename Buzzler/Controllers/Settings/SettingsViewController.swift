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
        self.navigationController?.navigationBar.topItem?.title = " "
        SideMenuManager.menuWidth = view.frame.width * CGFloat(0.64)
        addThinShadowToNav(from: self)

        setUI()
        setGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Settings"
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
    
    func setGesture() {
        let accountGesture = UITapGestureRecognizer(target: self, action: #selector(self.pushAccountVC(sender:)))
        self.vw_account.addGestureRecognizer(accountGesture)
        
        let csGesture = UITapGestureRecognizer(target: self, action: #selector(self.pushCsCenterVC(sender:)))
        self.vw_csCenter.addGestureRecognizer(csGesture)
    }
}

extension SettingsViewController {
    
    func pushAccountVC(sender: UITapGestureRecognizer) {
        let settingsAccountVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "SettingsAccountViewController") as! SettingsAccountViewController
        self.navigationController?.pushViewController(settingsAccountVC, animated: true)
    }
    
    func pushCsCenterVC(sender: UITapGestureRecognizer) {
        let customerVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "CustomerCenterViewController") as! CustomerCenterViewController
        self.navigationController?.pushViewController(customerVC, animated: true)
    }
}
