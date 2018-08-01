//
//  DeletePostPopUpViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 01/08/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import UIKit

class DeletePostPopUpViewController: UIViewController {

    @IBOutlet weak var btn_ok: UIButton!
    @IBOutlet weak var btn_cancel: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setButtonUI()
    }

    @IBAction func pressOK(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension DeletePostPopUpViewController {
    
    func setButtonUI() {
        btn_ok.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_ok.layer.borderWidth = 2.5
        btn_ok.layer.borderColor = Config.UI.buttonActiveColor.cgColor
        
        btn_cancel.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_cancel.layer.borderWidth = 2.5
        btn_cancel.layer.borderColor = Config.UI.buttonActiveColor.cgColor
    }
}
