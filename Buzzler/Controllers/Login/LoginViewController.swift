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
    @IBOutlet weak var btn_autoLogin: UIButton!
    @IBOutlet weak var btn_saveEmail: UIButton!
    
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
                self.btn_autoLogin.isEnabled = valid
                self.btn_saveEmail.isEnabled = valid
                self.btn_login.isEnabled = valid
                self.btn_login.layer.borderColor = valid ? Config.UI.buttonActiveColor.cgColor : Config.UI.buttonInActiveColor.cgColor
            })
            .addDisposableTo(disposeBag)
        
        viewModel.loginExecuting.drive(onNext: { (executing) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = executing
        }).addDisposableTo(disposeBag)
        
        viewModel.loginFinished.drive(onNext: { [weak self] loginResult in
            GlobalUIManager.loadHomeVC()
        }).addDisposableTo(disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let `self` = self else {return}

                self.view.bounds.origin.y = keyboardVisibleHeight * 0.7
                self.view.layoutIfNeeded()
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
        txt_password.placeholder = "Password"
        // txt_password.addBorderBottom(height: 1.0, color: Config.UI.textFieldColor)
        
        setBorderAndCornerRadius(layer: txt_email.layer, width: 1, radius: 20, color: Config.UI.textFieldColor)
        setBorderAndCornerRadius(layer: txt_password.layer, width: 1, radius: 20, color: Config.UI.textFieldColor)
        setLeftPadding(textField: txt_email)
        setLeftPadding(textField: txt_password)
        
        // button
        btn_autoLogin.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_autoLogin.setTitleColor(Config.UI.buttonInActiveColor, for: UIControlState.disabled)
        btn_saveEmail.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_saveEmail.setTitleColor(Config.UI.buttonInActiveColor, for: UIControlState.disabled)
        
        btn_login.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_login.setTitleColor(Config.UI.buttonInActiveColor, for: UIControlState.disabled)
        btn_login.layer.borderWidth = 2.5
        btn_login.layer.borderColor = Config.UI.buttonInActiveColor.cgColor
    }
    
    
}
