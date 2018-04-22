//
//  SignUpDoneViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 22..
//  Copyright © 2018년 Maru. All rights reserved.
//

import UIKit

class SignUpDoneViewController: UIViewController {

    @IBOutlet weak var btn_done: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    @IBAction func pressBackBtn(_ sender: UIBarButtonItem) {
        dismiss()
    }
    
    @IBAction func pressDone(_ sender: UIButton) {
        // TODO: push to login view
        dismiss()
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SignUpDoneViewController {
    
    func setUI() {
        // button
        btn_done.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_done.layer.borderWidth = 2.5
        btn_done.layer.borderColor = Config.UI.buttonActiveColor.cgColor
    }
}
