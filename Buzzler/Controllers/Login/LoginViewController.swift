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

class LoginViewController: UIViewController {
    
    let viewModel = LoginViewModel(provider: BuzzlerProvider)
    
    @IBOutlet weak var txt_email: UITextField!
    @IBOutlet weak var txt_password: UITextField!
    @IBOutlet weak var btn_login: UIButton!
    @IBOutlet weak var lbl_enabled: UILabel!
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToRx()
        setUI()
    }
    
    func bindToRx() {
        txt_email.rx.text.orEmpty.bind(to: viewModel.email).addDisposableTo(disposeBag)
        txt_password.rx.text.orEmpty.bind(to: viewModel.password).addDisposableTo(disposeBag)
        btn_login.rx.tap.bind(to: viewModel.loginTaps).addDisposableTo(disposeBag)
        
        viewModel.loginEnabled
            .drive(btn_login.rx.isEnabled)
            .addDisposableTo(disposeBag)
        
        viewModel.loginExecuting.drive(onNext: { (executing) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = executing
        }).addDisposableTo(disposeBag)
        
        viewModel.loginFinished.drive(onNext: { [weak self] loginResult in
            switch loginResult {
            case .failed(let message):
                let alert = UIAlertController(title: "Oops!", message:message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                self?.present(alert, animated: true, completion: nil)
            case .ok:
                self?.dismiss(animated: true, completion: nil)
            }
        }).addDisposableTo(disposeBag)
    }
    
    override func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension LoginViewController {
    
    func setUI() {
        txt_email.placeholder = "Collage’s E-mail"
        txt_email.addBorderBottom(height: 1.0, color: Config.UI.textFieldColor)
        
        txt_password.placeholder = "Password"
        txt_password.addBorderBottom(height: 1.0, color: UIColor.lightGray)
        
    }
    
}
