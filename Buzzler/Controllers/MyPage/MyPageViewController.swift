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

    @IBOutlet weak var lbl_univInfo: UILabel!
    @IBOutlet weak var lbl_buzAmount: UILabel!
    @IBOutlet weak var lbl_userName: UILabel!
    @IBOutlet weak var seg_univAndMajor: UISegmentedControl!
    @IBOutlet weak var tbl_post: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SideMenuManager.menuWidth = view.frame.width * CGFloat(0.64)
        deleteShadow(from: self)
        title = " "
        
        setSegmentControl()
    }
    
    func setSegmentControl() {
        self.seg_univAndMajor.addUnderlineForSelectedSegment()
    }
    
    @IBAction func segmentedControlDidChange(_ sender: UISegmentedControl) {
        self.seg_univAndMajor.changeUnderlinePosition()
        
        print(seg_univAndMajor.selectedSegmentIndex)
    }
}

