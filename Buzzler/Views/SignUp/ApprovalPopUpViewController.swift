//
//  ApprovalPopUpViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 23/07/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import UIKit

class ApprovalPopUpViewController: UIViewController {

    @IBOutlet weak var btn_ok: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setButtonUI()
    }
    
    @IBAction func pressedOK(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ApprovalPopUpViewController {
    
    func setButtonUI() {
        btn_ok.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_ok.layer.borderWidth = 2.5
        btn_ok.layer.borderColor = Config.UI.buttonActiveColor.cgColor
    }
}
