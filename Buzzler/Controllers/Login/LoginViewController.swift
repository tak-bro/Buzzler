//
//  LoginViewController.swift
//  Buzzler
//
//  Created by 진형탁 on 2018. 4. 18..
//  Copyright © 2018년 Maru. All rights reserved.
//

import UIKit
import Moya
import RxSwift
import RxCocoa
import RxKeyboard

class LoginViewController: UIViewController {
    
    let viewModel = LoginViewModel(provider: BuzzlerProvider)
    
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    @IBOutlet weak var btn_login: UIButton!
   
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToRx()
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
     func bindToRx() {
        txt_email.rx.text.orEmpty.bind(to: viewModel.email).addDisposableTo(disposeBag)
        txt_password.rx.text.orEmpty.bind(to: viewModel.password).addDisposableTo(disposeBag)
        btn_login.rx.tap.bind(to: viewModel.loginTaps).addDisposableTo(disposeBag)
        
        viewModel.loginEnabled
            .drive(onNext: { (valid) in
                self.btn_login.isEnabled = valid
                self.btn_login.layer.borderColor = valid ? Config.UI.buttonActiveColor.cgColor : Config.UI.buttonInActiveColor.cgColor
            })
            .addDisposableTo(disposeBag)
        
        viewModel.loginExecuting.drive(onNext: { (executing) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = executing
        }).addDisposableTo(disposeBag)
        
        viewModel.loginFinished.drive(onNext: { [weak self] loginResult in
            print(loginResult)
            GlobalUIManager.loadHomeVC()
        }).addDisposableTo(disposeBag)
    }
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension LoginViewController {
    
    func setUI() {
        // textfield
        txt_email.placeholder = "Collage’s E-mail"
        txt_email.addBorderBottom(height: 1.0, color: Config.UI.textFieldColor)
        txt_password.placeholder = "Password"
        txt_password.addBorderBottom(height: 1.0, color: Config.UI.textFieldColor)
        
        // button
        btn_login.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_login.setTitleColor(Config.UI.buttonInActiveColor, for: UIControlState.disabled)
        btn_login.layer.borderWidth = 2.5
        btn_login.layer.borderColor = Config.UI.buttonInActiveColor.cgColor
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
}
