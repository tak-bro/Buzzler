//
//  LastStepViewController.swift
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

class LastStepViewController: UIViewController {

    @IBOutlet weak var btn_submit: UIButton!
    @IBOutlet weak var txt_confirmPassword: UITextField!
    @IBOutlet weak var txt_newPassword: UITextField!
    @IBOutlet weak var lbl_error: UILabel!
    
    fileprivate let disposeBag = DisposeBag()
    let router = ResetPasswordRouter()
    var viewModel: LastStepViewModel?
    var userEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // remove "Back" text
        self.navigationController?.navigationBar.topItem?.title = " "
        bindToRx()
        setUI()
    }
    
    func bindToRx() {
        self.viewModel = LastStepViewModel(provider: BuzzlerProvider, userEmail: userEmail!)
        
        guard let viewModel = self.viewModel else { return }
        
        btn_submit.rx.tap
            .bind(to: viewModel.inputs.submitTaps)
            .disposed(by: disposeBag)

        txt_newPassword.rx.text.orEmpty
            .bind(to: viewModel.inputs.password)
            .disposed(by: disposeBag)

        txt_confirmPassword.rx.text.orEmpty
            .bind(to: viewModel.inputs.confirmPassword)
            .disposed(by: disposeBag)
        
        viewModel.outputs.enableNextButton.drive(onNext: { enable in
            self.btn_submit.isEnabled = enable
            self.btn_submit.layer.borderColor = enable ? Config.UI.buttonActiveColor.cgColor : Config.UI.buttonInActiveColor.cgColor
        }).disposed(by: disposeBag)
        
        viewModel.outputs.validatedPassword
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.outputs.validatedConfirmPassword
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.outputs.enableNextButton
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.outputs.requestNewPassword
            .drive(onNext: { success in
                if success == true {
                    self.router.perform(.doneReset, from: self)
                } else {
                    SVProgressHUD.showError(withStatus: "Failed to verify code for new password")
                }
            }).disposed(by: disposeBag)
        
        viewModel.isLoading
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
        
        viewModel.outputs.setErrorMessage
            .drive(onNext: { message in
                self.lbl_error.text = message
            }).disposed(by: disposeBag)
    }
    
}

extension LastStepViewController {
    
    func setUI() {
        // remove "Back" text
        self.navigationController?.navigationBar.topItem?.title = " "
        
        // button
        btn_submit.isEnabled = false
        btn_submit.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_submit.setTitleColor(Config.UI.buttonInActiveColor, for: UIControlState.disabled)
        btn_submit.layer.borderWidth = 2.5
        btn_submit.layer.borderColor = Config.UI.buttonInActiveColor.cgColor
        
        setBorderAndCornerRadius(layer: txt_newPassword.layer, width: 1, radius: 20, color: Config.UI.textFieldColor)
        setLeftPadding(textField: txt_newPassword)
        txt_confirmPassword.isSecureTextEntry = true
        
        setBorderAndCornerRadius(layer: txt_confirmPassword.layer, width: 1, radius: 20, color: Config.UI.textFieldColor)
        setLeftPadding(textField: txt_confirmPassword)
        txt_newPassword.isSecureTextEntry = true
    }
    
}

