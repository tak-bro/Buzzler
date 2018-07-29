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
import SVProgressHUD

class LoginViewController: UIViewController, ShowsAlert {
    
    let viewModel = LoginViewModel(provider: BuzzlerProvider)
    
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    @IBOutlet weak var btn_login: UIButton!
    @IBOutlet weak var btn_autoLogin: UIButton!
    @IBOutlet weak var btn_saveEmail: UIButton!
    
    var environment = Environment()
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // add subview for auto login
        addAppLogoView()
        
        // main logic
        bindToRx()
        setAutoLogin()
        setUI()
    }

     func bindToRx() {
        
        btn_login.rx.tap
            .bind(to:self.viewModel.inputs.loginTaps)
            .disposed(by: disposeBag)
        
        txt_email.rx.text.orEmpty
            .bind(to:self.viewModel.inputs.email)
            .disposed(by: disposeBag)
        
        txt_password.rx.text.orEmpty
            .bind(to:self.viewModel.inputs.password)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.enableLogin.drive(onNext: { enable in
            self.btn_login.isEnabled = enable
            self.btn_autoLogin.isEnabled = enable
            self.btn_saveEmail.isEnabled = enable
            self.btn_login.layer.borderColor = enable ? Config.UI.buttonActiveColor.cgColor : Config.UI.buttonInActiveColor.cgColor
        }).disposed(by: disposeBag)
        
        self.viewModel.outputs.validatedEmail
            .drive()
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.validatedPassword
            .drive()
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.enableLogin
            .drive()
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.signedIn
            .drive(onNext: { signedIn in
                if signedIn == true {
                    GlobalUIManager.loadHomeVC()
                } else {
                    self.showAlert(message: "Login Error!")
                    self.environment.autoLogin = false
                    self.environment.saveEmail = false
                    self.btn_saveEmail.setImage(UIImage(named: "btn_checkbox_empty"), for: .normal)
                    self.btn_autoLogin.setImage(UIImage(named: "btn_checkbox_empty"), for: .normal)
                    self.removeAppLogoView()
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
                guard let `self` = self else {return}

                self.view.bounds.origin.y = keyboardVisibleHeight * 0.7
                self.view.layoutIfNeeded()
            }).addDisposableTo(disposeBag)
    }
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func pressAutoLogin(_ sender: UIButton) {
        if let autoLogin = self.environment.autoLogin {
            if autoLogin {
                sender.setImage(UIImage(named: "btn_checkbox_empty"), for: .normal)
                self.environment.autoLogin = false
            } else {
                sender.setImage(UIImage(named: "btn_checkbox"), for: .normal)
                self.environment.autoLogin = true
            }
        } else {
            // if autoLogin is nil
            sender.setImage(UIImage(named: "btn_checkbox"), for: .normal)
            self.environment.autoLogin = true
        }
    }
    
    @IBAction func pressSaveEmail(_ sender: UIButton) {
        if let saveEmail = self.environment.saveEmail {
            if saveEmail {
                sender.setImage(UIImage(named: "btn_checkbox_empty"), for: .normal)
                self.environment.saveEmail = false
            } else {
                sender.setImage(UIImage(named: "btn_checkbox"), for: .normal)
                self.environment.saveEmail = true
            }
        } else {
            // if saveEmail is nil
            sender.setImage(UIImage(named: "btn_checkbox"), for: .normal)
            self.environment.saveEmail = true
        }
    }
}

extension LoginViewController {
    
    func setUI() {
        // textfield
        txt_email.placeholder = "Collage’s E-mail"
        txt_password.placeholder = "Password"
        txt_password.isSecureTextEntry = true
        // txt_password.addBorderBottom(height: 1.0, color: Config.UI.textFieldColor)

        setBorderAndCornerRadius(layer: txt_email.layer, width: 1, radius: 20, color: Config.UI.textFieldColor)
        setBorderAndCornerRadius(layer: txt_password.layer, width: 1, radius: 20, color: Config.UI.textFieldColor)
        setLeftPadding(textField: txt_email)
        setLeftPadding(textField: txt_password)
        
        // button
        self.btn_login.isEnabled = false
        self.btn_autoLogin.isEnabled = false
        self.btn_saveEmail.isEnabled = false
        
        btn_autoLogin.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_autoLogin.setTitleColor(Config.UI.buttonInActiveColor, for: UIControlState.disabled)
        btn_saveEmail.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_saveEmail.setTitleColor(Config.UI.buttonInActiveColor, for: UIControlState.disabled)
        
        btn_login.setTitleColor(Config.UI.buttonActiveColor, for: UIControlState.normal)
        btn_login.setTitleColor(Config.UI.buttonInActiveColor, for: UIControlState.disabled)
        btn_login.layer.borderWidth = 2.5
        btn_login.layer.borderColor = Config.UI.buttonInActiveColor.cgColor
    }
    
    func setAutoLogin() {
        if let autoLogin = environment.autoLogin {
            // set button image
            autoLogin ? self.btn_autoLogin.setImage(UIImage(named: "btn_checkbox"), for: .normal) : self.btn_autoLogin.setImage(UIImage(named: "btn_checkbox_empty"), for: .normal)
            if autoLogin == true {
                self.viewModel.inputs.email.on(.next(environment.receiver))
                self.viewModel.inputs.password.on(.next(environment.password))
                // event publish
                self.viewModel.inputs.loginTaps.on(.next())
            } else {
                removeAppLogoView()
            }
        } else {
            removeAppLogoView()
        }
        
        if let saveEmail = environment.saveEmail {
            // set button image
            saveEmail ? self.btn_saveEmail.setImage(UIImage(named: "btn_checkbox"), for: .normal) : self.btn_saveEmail.setImage(UIImage(named: "btn_checkbox_empty"), for: .normal)
            if saveEmail == true {
                // event publish
                self.txt_email.text = environment.receiver
                self.viewModel.inputs.email.on(.next(environment.receiver))
            }
        }
    }
    
    func addAppLogoView() {
        let appLogoView = AppLogoView.instanceFromNib()
        appLogoView.frame = self.view.frame
        appLogoView.tag = 100
        self.view.addSubview(appLogoView)
    }
    
    func removeAppLogoView() {
        self.view.viewWithTag(100)?.removeFromSuperview()
    }
}
