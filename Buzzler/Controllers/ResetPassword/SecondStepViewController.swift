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

class SecondStepViewController: UIViewController, ShowsAlert {

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
                    .textColor(Config.UI.errorColor),
                    .font(.AvenirNext(type: .Book, size: 12))
                    ])
                self?.lbl_timer.attributedText = invalidateText
            }
        )
    }()
    
    fileprivate let disposeBag = DisposeBag()
    
    let router = ResetPasswordRouter()
    var viewModel: SecondStepViewModel?
    var userEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // remove "Back" text
        self.navigationController?.navigationBar.topItem?.title = " "
        self.timer.start()
        bindToRx()
        setUI()
    }
    
    func bindToRx() {
        self.viewModel = SecondStepViewModel(provider: BuzzlerProvider, userEmail: userEmail!)
        
        guard let secondStepViewModel = self.viewModel else { return }
        
        btn_next.rx.tap
            .bind(to: secondStepViewModel.inputs.nextTaps)
            .disposed(by: disposeBag)
        
        btn_resend.rx.tap
            .bind(to: secondStepViewModel.inputs.resendTaps)
            .disposed(by: disposeBag)
        
        txt_code.rx.text.orEmpty
            .bind(to: secondStepViewModel.inputs.code)
            .disposed(by: disposeBag)
        
        secondStepViewModel.outputs.enableNextButton.drive(onNext: { enable in
            self.btn_next.isEnabled = enable
            self.btn_next.layer.borderColor = enable ? Config.UI.buttonActiveColor.cgColor : Config.UI.buttonInActiveColor.cgColor
        }).disposed(by: disposeBag)
        
        secondStepViewModel.outputs.validatedCode
            .drive()
            .disposed(by: disposeBag)
        
        secondStepViewModel.outputs.enableNextButton
            .drive()
            .disposed(by: disposeBag)
        
        secondStepViewModel.outputs.verifyCode
            .drive(onNext: { signedIn in
                if signedIn == true {
                    // push view controller
                    self.router.email = self.userEmail!
                    self.router.perform(.lastStep, from: self)
                } else {
                    self.showAlert(message: "Failed to verify code for new password")
                }
            }).disposed(by: disposeBag)
        
        secondStepViewModel.outputs.resendCode
            .drive(onNext: { resend in
                if resend == true {
                    print(resend)
                    // resend code
                    self.timer.restart()
                } else {
                    self.showAlert(message: "Failed to resend code for new password")
                }
            }).disposed(by: disposeBag)
        
        secondStepViewModel.isLoading
            .drive(onNext: { isLoading in
                switch isLoading {
                case true:
                    SVProgressHUD.show()
                    break
                case false:
                    SVProgressHUD.dismiss()
                    break
                }
            }).disposed(by: disposeBag)
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

