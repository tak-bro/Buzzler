//
//  SecondStepViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 18/05/2018.
//  Copyright © 2018 Maru. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import RxKeyboard
import SVProgressHUD
import AsyncTimer

class SecondStepViewController: UIViewController {

    @IBOutlet weak var btn_resend: UIButton!
    @IBOutlet weak var btn_next: UIButton!
    @IBOutlet weak var txt_code: UITextField!
    @IBOutlet weak var lbl_timer: UILabel!
    
    // timer
    private lazy var timer: AsyncTimer = {
        return AsyncTimer(
            interval: .milliseconds(1000),
            times: 180,
            block: { [weak self] value in
                if let remainTime = Int(value.description) {
                    self?.lbl_timer.text = seconds2Timestamp(intSeconds: remainTime)
                }
            }, completion: { [weak self] in
                // show invalidate text
                let invalidateText = "invalidated".withAttributes([
                    .textColor(Config.UI.errorFontColor),
                    .font(.AvenirNext(type: .Book, size: 12))
                    ])
                self?.lbl_timer.attributedText = invalidateText
            }
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        
        self.timer.start()
    }
    
}

extension SecondStepViewController {
    
    func setUI() {
        // remove "Back" text
        self.navigationController?.navigationBar.topItem?.title = " "
        
        // button
        btn_next.isEnabled = false
        btn_next.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_next.setTitleColor(Config.UI.buttonInActiveColor, for: UIControlState.disabled)
        btn_next.layer.borderWidth = 2.5
        btn_next.layer.borderColor = Config.UI.buttonInActiveColor.cgColor
        
        setBorderAndCornerRadius(layer: txt_code.layer, width: 1, radius: 20, color: Config.UI.textFieldColor)
        setLeftPadding(textField: txt_code)
    }

}

