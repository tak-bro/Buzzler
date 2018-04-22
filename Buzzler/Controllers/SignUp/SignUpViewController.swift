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
    @IBOutlet weak var btn_next: UIButton!
    
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
        btn_next.rx.tap.bind(to: viewModel.nextTaps).addDisposableTo(disposeBag)
        
        viewModel.nextEnabled
            .drive(onNext: { (valid) in
                self.btn_next.isEnabled = valid
                self.btn_next.layer.borderColor = valid ? Config.UI.buttonActiveColor.cgColor : Config.UI.buttonInActiveColor.cgColor
            })
            .addDisposableTo(disposeBag)
        
        viewModel.nextExecuting.drive(onNext: { (executing) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = executing
        }).addDisposableTo(disposeBag)
        
        viewModel.nextFinished.drive(onNext: { [weak self] loginResult in
            // push view controller
            guard let strongSelf = self else { return }
            strongSelf.router.perform(.verifyCode, from: strongSelf)
        }).addDisposableTo(disposeBag)
        
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let `self` = self else { return }
                self.view.bounds.origin.y = keyboardVisibleHeight * 0.5
                self.view.layoutIfNeeded()
            }).addDisposableTo(disposeBag)
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
        
        setBorderAndCornerRadius(layer: txt_nickName.layer, width: 1, radius: 25, color: Config.UI.textFieldColor)
        setBorderAndCornerRadius(layer: txt_email.layer, width: 1, radius: 25, color: Config.UI.textFieldColor)
        setBorderAndCornerRadius(layer: txt_password.layer, width: 1, radius: 25, color: Config.UI.textFieldColor)
        
        setLeftPadding(textField: txt_nickName)
        setLeftPadding(textField: txt_email)
        setLeftPadding(textField: txt_password)
    }
}

