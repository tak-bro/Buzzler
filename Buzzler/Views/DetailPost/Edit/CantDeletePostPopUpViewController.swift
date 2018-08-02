//
//  CantDeletePostPopUpViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 01/08/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import UIKit

class CantDeletePostPopUpViewController: UIViewController {

    @IBOutlet weak var btn_ok: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtonUI()
    }
    
    @IBAction func pressOK(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension CantDeletePostPopUpViewController {
    
    func setButtonUI() {
        btn_ok.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_ok.layer.borderWidth = 2.5
        btn_ok.layer.borderColor = Config.UI.buttonActiveColor.cgColor
    }
}
