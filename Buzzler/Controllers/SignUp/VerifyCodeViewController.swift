//
//  VerifyCodeViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 21..
//  Copyright © 2018년 Maru. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import RxKeyboard
import SVProgressHUD

class VerifyCodeViewController: UIViewController {

    @IBOutlet weak var txt_code: UITextField!
    @IBOutlet weak var btn_next: UIButton!
    @IBOutlet weak var btn_resend: UIButton!
    @IBOutlet weak var lbl_timer: UILabel!
    
    //timer
    var mTimer: Timer?
    var remainTime: Int = 180
    var inputUserInfo = UserInfo()

    fileprivate let disposeBag = DisposeBag()
    
    let router = SignUpRouter()
    var viewModel: VerifyCodeViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // remove "Back" text
        self.navigationController?.navigationBar.topItem?.title = " "
        bindToRx()
        setUI()
        setTimer()
    }
    
    func bindToRx() {
        self.viewModel = VerifyCodeViewModel(provider: BuzzlerProvider, userInfo: inputUserInfo)
        
        guard let verifyCodeViewModel = self.viewModel else { return }
        
        btn_next.rx.tap
            .bind(to: verifyCodeViewModel.inputs.nextTaps)
            .disposed(by: disposeBag)
        
        btn_resend.rx.tap
            .bind(to: verifyCodeViewModel.inputs.resendTaps)
            .disposed(by: disposeBag)

        txt_code.rx.text.orEmpty
            .bind(to: verifyCodeViewModel.inputs.code)
            .disposed(by: disposeBag)
        
        verifyCodeViewModel.outputs.enableNextButton.drive(onNext: { enable in
            self.btn_next.isEnabled = enable
            self.btn_next.layer.borderColor = enable ? Config.UI.buttonActiveColor.cgColor : Config.UI.buttonInActiveColor.cgColor
        }).disposed(by: disposeBag)
        
        verifyCodeViewModel.outputs.validatedCode
            .drive()
            .disposed(by: disposeBag)
        
        verifyCodeViewModel.outputs.enableNextButton
            .drive()
            .disposed(by: disposeBag)
        
        verifyCodeViewModel.outputs.verifyCode
            .drive(onNext: { signedIn in
                if signedIn == true {
                    print(signedIn)
                    // push view controller
                    self.router.userInfo = self.inputUserInfo
                    self.router.perform(.selectMajor, from: self)
                } else {
                    SVProgressHUD.showError(withStatus: "Failed to verify code")
                }
            }).disposed(by: disposeBag)
        
        verifyCodeViewModel.outputs.resendCode
            .drive(onNext: { resend in
                if resend == true {
                    print(resend)
                    // resend code
                    self.remainTime = 180
                    self.setTimer()
                } else {
                    SVProgressHUD.showError(withStatus: "Failed to resend code")
                }
            }).disposed(by: disposeBag)
        
        verifyCodeViewModel.isLoading
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
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func pressResend(_ sender: UIButton) {
        remainTime = 180
        setTimer()
    }
}

extension VerifyCodeViewController {
    
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

    func setTimer() {
        if let timer = mTimer {
            if !timer.isValid {
                mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
            }
        } else {
            mTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
        }
    }

    func timerCallback() {
        remainTime -= 1
        lbl_timer.text = seconds2Timestamp(intSeconds: remainTime)
        if (remainTime <= 0) {
            // show invalidate text
            let invalidateText = "invalidated".withAttributes([
                .textColor(UIColor.red),
                .font(.AvenirNext(type: .Book, size: 12))
                ])
            lbl_timer.attributedText = invalidateText
            timerEnd()
        }
    }
    
    func timerEnd() {
        if let timer = mTimer {
            if (timer.isValid) {
                timer.invalidate()
            }
        }
        remainTime = 0
    }
    
    fileprivate func hideKeyboard() {
        self.txt_code.resignFirstResponder()
    }
    
    fileprivate func resetTextField() {
        self.txt_code.text = ""
    }

}

