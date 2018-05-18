//
//  LastStepViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 18/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import UIKit

class LastStepViewController: UIViewController {

    @IBOutlet weak var btn_submit: UIButton!
    @IBOutlet weak var txt_confirmPassword: UITextField!
    @IBOutlet weak var txt_newPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
}

extension LastStepViewController {
    
    func setUI() {
        // remove "Back" text
        self.navigationController?.navigationBar.topItem?.title = " "
        
        // button
        btn_submit.isEnabled = false
        btn_submit.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_submit.setTitleColor(Config.UI.buttonInActiveColor, for: UIControlState.disabled)
        btn_submit.layer.borderWidth = 2.5
        btn_submit.layer.borderColor = Config.UI.buttonInActiveColor.cgColor
        
        setBorderAndCornerRadius(layer: txt_confirmPassword.layer, width: 1, radius: 20, color: Config.UI.textFieldColor)
        setLeftPadding(textField: txt_confirmPassword)
        
        setBorderAndCornerRadius(layer: txt_newPassword.layer, width: 1, radius: 20, color: Config.UI.textFieldColor)
        setLeftPadding(textField: txt_newPassword)
    }
    
}

