//
//  TermsAndConditionsViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 04/09/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import UIKit

class TermsAndConditionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.topItem?.title = " "
        addThinShadowToNav(from: self)
        title = "이용약관"
    }
}
