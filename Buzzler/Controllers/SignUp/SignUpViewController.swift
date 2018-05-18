//
//  SignUpViewController.swift
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

class SignUpViewController: UIViewController {
    
    let router = SignUpRouter()
    let viewModel = SignUpViewModel(provider: BuzzlerProvider)
    
    @IBOutlet weak var txt_nickName: UITextField!
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    @IBOutlet weak var txt_confirmPassword: UITextField!
    @IBOutlet weak var btn_next: UIButton!
    @IBOutlet weak var lbl_error: UILabel!
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // remove "Back" text
        self.navigationController?.navigationBar.topItem?.title = " "
        bindToRx()
        setUI()
    }

    func bindToRx() {

        btn_next.rx.tap
            .bind(to:self.viewModel.inputs.nextTaps)
            .disposed(by: disposeBag)
        
        txt_email.rx.text.orEmpty
            .bind(to:self.viewModel.inputs.email)
            .disposed(by: disposeBag)
        
        txt_password.rx.text.orEmpty
            .bind(to:self.viewModel.inputs.password)
            .disposed(by: disposeBag)
        
        txt_confirmPassword.rx.text.orEmpty
            .bind(to:self.viewModel.inputs.confirmPassword)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.enableNextButton.drive(onNext: { enable in
            self.btn_next.isEnabled = enable
            self.btn_next.layer.borderColor = enable ? Config.UI.buttonActiveColor.cgColor : Config.UI.buttonInActiveColor.cgColor
        }).disposed(by: disposeBag)
        
        self.viewModel.outputs.setErrorMessage.drive(onNext: { message in
            self.lbl_error.text = message
        }).disposed(by: disposeBag)
        
        self.viewModel.outputs.validatedEmail
            .drive()
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.validatedPassword
            .drive()
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.enableNextButton
            .drive()
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.requestCode
            .drive(onNext: { signedIn in
                if signedIn == true {
                    print(signedIn)
                    guard let receiver = self.txt_email.text,
                        let nickName = self.txt_nickName.text,
                        let password = self.txt_password.text else { return }
                    
                    // push view controller
                    let inputInfo = UserInfo(receiver: receiver,
                                             nickName: nickName,
                                             password: password)
                    self.router.userInfo = inputInfo
                    self.router.perform(.verifyCode, from: self)
                } else {
                    SVProgressHUD.showError(withStatus: "Server Error")
                }
            }).disposed(by: disposeBag)
        
        self.viewModel.isLoading
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

        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let `self` = self else { return }
                self.view.bounds.origin.y = keyboardVisibleHeight * 0.5
                self.view.layoutIfNeeded()
            })
            .addDisposableTo(disposeBag)
    }
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func pressDismiss(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension SignUpViewController {
    
    func setUI() {
        // button
        btn_next.isEnabled = false
        btn_next.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_next.setTitleColor(Config.UI.buttonInActiveColor, for: UIControlState.disabled)
        btn_next.layer.borderWidth = 2.5
        btn_next.layer.borderColor = Config.UI.buttonInActiveColor.cgColor
        
        setBorderAndCornerRadius(layer: txt_nickName.layer, width: 1, radius: 20, color: Config.UI.textFieldColor)
        setBorderAndCornerRadius(layer: txt_email.layer, width: 1, radius: 20, color: Config.UI.textFieldColor)
        setBorderAndCornerRadius(layer: txt_password.layer, width: 1, radius: 20, color: Config.UI.textFieldColor)
        setBorderAndCornerRadius(layer: txt_confirmPassword.layer, width: 1, radius: 20, color: Config.UI.textFieldColor)
        
        setLeftPadding(textField: txt_nickName)
        setLeftPadding(textField: txt_email)
        setLeftPadding(textField: txt_password)
        setLeftPadding(textField: txt_confirmPassword)
        
        txt_password.isSecureTextEntry = true
        txt_confirmPassword.isSecureTextEntry = true
    }
    
    fileprivate func hideKeyboard() {
        self.txt_nickName.resignFirstResponder()
        self.txt_email.resignFirstResponder()
        self.txt_password.resignFirstResponder()
        self.txt_confirmPassword.resignFirstResponder()
    }
    
    fileprivate func resetTextField() {
        self.txt_nickName.text = ""
        self.txt_email.text = ""
        self.txt_password.text = ""
        self.txt_confirmPassword.text = ""
    }
}

