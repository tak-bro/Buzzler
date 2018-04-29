//
//  SideViewController.swift
//  Buzzler
//
//  Created by Tak on 2018/04/08.
//  Copyright © 2018年 Tak. All rights reserved.
//

import UIKit

class SideViewController: UITableViewController {

    @IBOutlet weak var vw_header: UIView!
    @IBOutlet weak var vw_footer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        vw_header.backgroundColor = Config.UI.themeColor
        vw_footer.backgroundColor = Config.UI.themeColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func pressDismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension SideViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NotificationCenter.default.post(name: NSNotification.Name.category, object: indexPath)
    }
}
