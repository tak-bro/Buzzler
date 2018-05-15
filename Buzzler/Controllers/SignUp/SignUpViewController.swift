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

class SignUpViewController: UIViewController {
    
    enum Route: String {
        case signUp
        case verifyCode
        case finish
    }
    
    let router = SignUpRouter()
    let viewModel = SignUpViewModel(provider: BuzzlerProvider)
    
    @IBOutlet weak var txt_nickName: UITextField!
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    @IBOutlet weak var txt_confirmPassword: UITextField!
    @IBOutlet weak var btn_next: UIButton!
    
    @IBOutlet weak var ind_activity: UIActivityIndicatorView!
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // remove "Back" text
        self.navigationController?.navigationBar.topItem?.title = " "
        bindToRx()
        setUI()
    }

    func bindToRx() {
        txt_nickName.rx.text.orEmpty.bind(to: viewModel.nickName).addDisposableTo(disposeBag)
        txt_email.rx.text.orEmpty.bind(to: viewModel.email).addDisposableTo(disposeBag)
        txt_password.rx.text.orEmpty.bind(to: viewModel.password).addDisposableTo(disposeBag)
        
        viewModel.activityIndicator
            .distinctUntilChanged()
            .drive(onNext: { [unowned self] active in
                self.hideKeyboard()
                self.ind_activity.isHidden = !active
                active ? self.ind_activity.startAnimating() : self.ind_activity.stopAnimating()
                self.btn_next.isEnabled = !active
                self.btn_next.layer.borderColor = !active ? Config.UI.buttonActiveColor.cgColor : Config.UI.buttonInActiveColor.cgColor
            })
            .addDisposableTo(disposeBag)
        
        viewModel.nextEnabled
            .drive(onNext: { (valid) in
                self.btn_next.isEnabled = valid
                self.btn_next.layer.borderColor = valid ? Config.UI.buttonActiveColor.cgColor : Config.UI.buttonInActiveColor.cgColor
            })
            .addDisposableTo(disposeBag)

        btn_next.rx.tap
            .withLatestFrom(viewModel.nextEnabled)
            .filter { $0 }
            .flatMapLatest { [unowned self] valid -> Observable<SignUpResult> in
                self.viewModel.requestCode(self.txt_email.text!)
                    .trackActivity(self.viewModel.activityIndicator)
            }
            .subscribe(onNext: { [unowned self] signUpResult in
                switch signUpResult {
                case .ok:
                    guard let receiver = self.txt_email.text,
                        let nickName = self.txt_nickName.text,
                        let password = self.txt_password.text else { return }
                    
                    // push view controller
                    let inputInfo = UserInfo(receiver: receiver,
                                             nickName: nickName,
                                             password: password)
                    self.router.userInfo = inputInfo
                    self.router.perform(.verifyCode, from: self)
                    break
                case .failed(let message):
                    self.resetTextField()
                    
                    let alert = UIAlertController(title: "Error!", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                    self.present(alert, animated: true, completion: nil)
                    break
                }
            })
            .addDisposableTo(disposeBag)
        
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

