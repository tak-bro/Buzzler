//
//  MyPageViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 20/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import UIKit
import SideMenu

class MyPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        SideMenuManager.menuWidth = view.frame.width * CGFloat(0.64)
    }

}
