//
//  StartSignUpViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 21..
//  Copyright © 2018년 Maru. All rights reserved.
//

import UIKit

class StartSignUpViewController: UIViewController {

    @IBOutlet weak var btn_getStarted: UIButton!
    @IBOutlet weak var btn_login: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        // remove "Back" text
        self.navigationController?.navigationBar.topItem?.title = " "
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension StartSignUpViewController {
    
    func setUI() {
        // button
        btn_getStarted.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_getStarted.layer.borderWidth = 2.5
        btn_getStarted.layer.borderColor = Config.UI.buttonActiveColor.cgColor
    }
    
}
