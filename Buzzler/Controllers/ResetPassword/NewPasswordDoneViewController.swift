//
//  NewPasswordDoneViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 25/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import UIKit

class NewPasswordDoneViewController: UIViewController {

    @IBOutlet weak var btn_start: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }

    @IBAction func pressStart(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressDismiss(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setUI() {
        // button
        btn_start.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_start.layer.borderWidth = 2.5
        btn_start.layer.borderColor = Config.UI.buttonActiveColor.cgColor
    }
}
