//
//  PostViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 17..
//  Copyright © 2018년 Maru. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var lbl_univ: UILabel!
    @IBOutlet weak var btn_post: UIButton!
    @IBOutlet weak var btn_dismiss: UIButton!
    @IBOutlet weak var txt_title: UITextField!
    @IBOutlet weak var txt_contents: UITextField!
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Actions
    
    @IBAction func pressDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
